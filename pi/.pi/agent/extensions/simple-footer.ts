/**
 * Simple Footer Extension
 *
 * Shows: cwd (branch) • ↑input ↓output $cost context% codex-limits provider/model • thinking
 */

import type { AssistantMessage } from "@earendil-works/pi-ai";
import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";

const CODEX_PROVIDER_ID = "openai-codex";
const CODEX_USAGE_URL = "https://chatgpt.com/backend-api/wham/usage";
const CODEX_USAGE_TTL_MS = 5 * 60 * 1000;
const CODEX_USAGE_TIMEOUT_MS = 15_000;

type CodexWindow = {
	usedPercent: number;
	windowSeconds?: number;
	resetsAt?: number;
};

type CodexUsage = {
	primary?: CodexWindow;
	secondary?: CodexWindow;
};

function formatTokens(count: number): string {
	if (count < 1000) return count.toString();
	if (count < 10000) return `${(count / 1000).toFixed(1)}k`;
	if (count < 1000000) return `${Math.round(count / 1000)}k`;
	if (count < 10000000) return `${(count / 1000000).toFixed(1)}M`;
	return `${Math.round(count / 1000000)}M`;
}

function isOpenAICodex(ctx: ExtensionContext): boolean {
	return ctx.model?.provider === CODEX_PROVIDER_ID;
}

function asObject(value: unknown): Record<string, unknown> | undefined {
	return value && typeof value === "object" && !Array.isArray(value)
		? (value as Record<string, unknown>)
		: undefined;
}

function asNumber(value: unknown): number | undefined {
	if (typeof value === "number" && Number.isFinite(value)) return value;
	if (typeof value === "string" && value.trim()) {
		const parsed = Number(value);
		if (Number.isFinite(parsed)) return parsed;
	}
	return undefined;
}

function parseCodexWindow(value: unknown): CodexWindow | undefined {
	const window = asObject(value);
	if (!window) return undefined;

	const usedPercent = asNumber(window.used_percent);
	if (usedPercent === undefined) return undefined;

	return {
		usedPercent,
		windowSeconds: asNumber(window.limit_window_seconds),
		resetsAt: asNumber(window.reset_at),
	};
}

function parseCodexUsage(payload: unknown): CodexUsage | undefined {
	const root = asObject(payload);
	const rateLimit = asObject(root?.rate_limit);
	if (!rateLimit) return undefined;

	const usage = {
		primary: parseCodexWindow(rateLimit.primary_window),
		secondary: parseCodexWindow(rateLimit.secondary_window),
	};

	return usage.primary || usage.secondary ? usage : undefined;
}

function clampPercent(value: number): number {
	return Math.min(100, Math.max(0, value));
}

function formatRemainingPercent(window: CodexWindow): string {
	return `${Math.round(100 - clampPercent(window.usedPercent))}%`;
}

function formatRemainingTime(window: CodexWindow): string {
	if (!window.resetsAt) return "?";

	const ms = Math.max(0, window.resetsAt * 1000 - Date.now());
	const hours = ms / 3_600_000;
	if (hours < 24) return `${formatOneDecimal(hours)}h`;
	return `${formatOneDecimal(hours / 24)}d`;
}

function formatOneDecimal(value: number): string {
	const rounded = Math.round(value * 10) / 10;
	return Number.isInteger(rounded) ? String(rounded) : rounded.toFixed(1);
}

function formatCodexUsage(usage: CodexUsage): string {
	const parts: string[] = [];
	if (usage.primary) {
		parts.push(
			`5h ${formatRemainingPercent(usage.primary)} ${formatRemainingTime(usage.primary)}`,
		);
	}
	if (usage.secondary) {
		parts.push(
			`1w ${formatRemainingPercent(usage.secondary)} ${formatRemainingTime(usage.secondary)}`,
		);
	}
	return parts.join("  ");
}

async function fetchCodexUsage(ctx: ExtensionContext): Promise<CodexUsage | undefined> {
	const model = ctx.model;
	if (!model) return undefined;

	const auth = await ctx.modelRegistry.getApiKeyAndHeaders(model);
	if (!auth.ok) throw new Error(auth.error);

	const headers = { ...auth.headers };
	if (!Object.keys(headers).some((key) => key.toLowerCase() === "authorization")) {
		if (!auth.apiKey) return undefined;
		headers.Authorization = `Bearer ${auth.apiKey}`;
	}
	if (!Object.keys(headers).some((key) => key.toLowerCase() === "user-agent")) {
		headers["User-Agent"] = "pi-simple-footer";
	}

	const controller = new AbortController();
	const timeout = setTimeout(() => controller.abort(), CODEX_USAGE_TIMEOUT_MS);
	try {
		const response = await fetch(CODEX_USAGE_URL, {
			headers,
			signal: controller.signal,
		});
		if (!response.ok) return undefined;
		return parseCodexUsage(await response.json());
	} finally {
		clearTimeout(timeout);
	}
}

export default function (pi: ExtensionAPI) {
	let enabled = false;
	let codexUsage = "";
	let codexUsageFetchedAt = 0;
	let codexUsageFetching = false;
	let activeRender: (() => void) | undefined;

	const refreshCodexUsage = (ctx: ExtensionContext, force = false) => {
		if (!isOpenAICodex(ctx)) {
			codexUsage = "";
			codexUsageFetchedAt = 0;
			return;
		}
		if (codexUsageFetching) return;
		if (!force && Date.now() - codexUsageFetchedAt < CODEX_USAGE_TTL_MS) return;

		codexUsageFetching = true;
		void fetchCodexUsage(ctx)
			.then((usage) => {
				codexUsage = usage ? formatCodexUsage(usage) : "";
				codexUsageFetchedAt = Date.now();
				activeRender?.();
			})
			.catch(() => {
				codexUsage = "";
				codexUsageFetchedAt = Date.now();
			})
			.finally(() => {
				codexUsageFetching = false;
			});
	};

	const createFooter =
		(ctx: ExtensionContext) => (tui: any, theme: any, footerData: any) => {
			activeRender = () => tui.requestRender();
			const unsub = footerData.onBranchChange(() => tui.requestRender());

			return {
				dispose: () => {
					activeRender = undefined;
					unsub();
				},
				invalidate() {},
				render(width: number): string[] {
					refreshCodexUsage(ctx);

					// Compute tokens
					let input = 0,
						output = 0,
						cost = 0;
					let thinkingLevel = "off";

					for (const e of ctx.sessionManager.getEntries()) {
						if (e.type === "message" && e.message.role === "assistant") {
							const m = e.message as AssistantMessage;
							input += m.usage.input;
							output += m.usage.output;
							cost += m.usage.cost.total;
						} else if (e.type === "thinking_level_change") {
							// @ts-ignore
							thinkingLevel = e.thinkingLevel;
						}
					}

					// CWD with ~
					let cwd = ctx.sessionManager.getCwd();
					const home = process.env.HOME || process.env.USERPROFILE;
					if (home && cwd.startsWith(home)) {
						cwd = `~${cwd.slice(home.length)}`;
					}

					// Add branch
					const branch = footerData.getGitBranch();
					if (branch) cwd = `${cwd} ${branch}`;

					// Context usage
					const contextUsage = ctx.getContextUsage?.();
					const contextWindow =
						contextUsage?.contextWindow ?? ctx.model?.contextWindow ?? 0;
					const contextPercentValue = contextUsage?.percent ?? 0;
					const contextPercent =
						contextUsage?.percent != null
							? `${contextPercentValue.toFixed(1)}%/${formatTokens(contextWindow)}`
							: `?/${formatTokens(contextWindow)}`;

					// Stats with color for context
					let contextStr: string;
					if (contextPercentValue > 90)
						contextStr = theme.fg("error", contextPercent);
					else if (contextPercentValue > 70)
						contextStr = theme.fg("warning", contextPercent);
					else contextStr = contextPercent;

					const statsParts = [
						`↑${formatTokens(input)}`,
						`↓${formatTokens(output)}`,
						`$${cost.toFixed(3)}`,
						contextStr,
					];
					let stats = statsParts.join(" ");
					if (isOpenAICodex(ctx) && codexUsage) stats += ` • ${codexUsage}`;

					// Left side: cwd • stats
					const leftText = `${cwd} • ${stats}`;
					const leftWidth = visibleWidth(leftText);

					// Right side: provider/model • thinking
					const modelName = ctx.model?.id || "no-model";
					const provider = ctx.model?.provider || "";
					let rightSide = provider ? `${provider}/${modelName}` : modelName;

					if (ctx.model?.reasoning) {
						rightSide =
							thinkingLevel === "off"
								? `${rightSide} • thinking off`
								: `${rightSide} • ${thinkingLevel}`;
					}

					// Layout with padding
					const rightWidth = visibleWidth(rightSide);
					const minPadding = 2;
					const totalNeeded = leftWidth + minPadding + rightWidth;

					let line: string;
					if (totalNeeded <= width) {
						const padding = " ".repeat(width - leftWidth - rightWidth);
						line = leftText + padding + rightSide;
					} else {
						const avail = width - leftWidth - minPadding;
						if (avail > 0) {
							const truncated = truncateToWidth(rightSide, avail, "");
							const pad = " ".repeat(
								Math.max(0, width - leftWidth - visibleWidth(truncated)),
							);
							line = leftText + pad + truncated;
						} else {
							line = truncateToWidth(leftText, width, "...");
						}
					}

					return [theme.fg("dim", truncateToWidth(line, width))];
				},
			};
		};

	pi.registerCommand("simple-footer", {
		description: "Toggle simple footer",
		handler: async (_args, ctx) => {
			enabled = !enabled;

			if (enabled) {
				ctx.ui.setFooter(createFooter(ctx));
				refreshCodexUsage(ctx, true);
				ctx.ui.notify("Simple footer enabled", "info");
			} else {
				ctx.ui.setFooter(undefined);
				ctx.ui.notify("Default footer restored", "info");
			}
		},
	});

	pi.on("model_select", (_event, ctx) => {
		codexUsage = "";
		codexUsageFetchedAt = 0;
		refreshCodexUsage(ctx, true);
		activeRender?.();
	});

	pi.on("session_start", (_event, ctx) => {
		enabled = true;
		ctx.ui.setFooter(createFooter(ctx));
		refreshCodexUsage(ctx, true);
	});
}
