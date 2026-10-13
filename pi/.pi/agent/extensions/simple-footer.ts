/**
 * Simple Footer Extension
 *
 * Shows: cwd (branch) • [$cost for API usage] context% provider limits provider/model • thinking
 */

import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";

const CODEX_PROVIDER_ID = "openai-codex";
const OPENCODE_GO_PROVIDER_ID = "opencode-go";
const SUBSCRIPTION_PROVIDER_IDS = new Set([
	CODEX_PROVIDER_ID,
	"github-copilot",
	"kimi-coding",
	OPENCODE_GO_PROVIDER_ID,
	"qwen-token-plan",
	"qwen-token-plan-cn",
	"xiaomi-token-plan-ams",
	"xiaomi-token-plan-cn",
	"xiaomi-token-plan-sgp",
	"zai",
	"zai-coding-cn",
]);
const OAUTH_SUBSCRIPTION_PROVIDER_IDS = new Set(["radius", "xai"]);
const USAGE_URLS = {
	[CODEX_PROVIDER_ID]: "https://chatgpt.com/backend-api/wham/usage",
	[OPENCODE_GO_PROVIDER_ID]: "https://opencode.ai/zen/go/v1/usage",
} as const;
const USAGE_TTL_MS = 60 * 1000;
const USAGE_TIMEOUT_MS = 15_000;

type UsageProvider = keyof typeof USAGE_URLS;
type UsageWindow = {
	usedPercent: number;
	windowSeconds?: number;
	resetsAt?: number;
};

type CodexUsage = {
	primary?: UsageWindow;
	secondary?: UsageWindow;
};

type OpenCodeGoUsage = {
	rolling?: UsageWindow;
	weekly?: UsageWindow;
	monthly?: UsageWindow;
};

function usageProvider(ctx: ExtensionContext): UsageProvider | undefined {
	const provider = ctx.model?.provider;
	return provider === CODEX_PROVIDER_ID || provider === OPENCODE_GO_PROVIDER_ID
		? provider
		: undefined;
}

function formatTokens(count: number): string {
	if (count < 1000) return count.toString();
	if (count < 10000) return `${(count / 1000).toFixed(1)}k`;
	if (count < 1000000) return `${Math.round(count / 1000)}k`;
	if (count < 10000000) return `${(count / 1000000).toFixed(1)}M`;
	return `${Math.round(count / 1000000)}M`;
}

function formatCost(cost: number): string {
	if (cost < 1) return `$${cost.toFixed(3)}`;
	if (cost < 100) return `$${cost.toFixed(1)}`;
	return `$${Math.round(cost)}`;
}

function isUsingSubscription(ctx: ExtensionContext): boolean {
	if (!ctx.model) return false;
	const provider = ctx.model.provider;
	return (
		SUBSCRIPTION_PROVIDER_IDS.has(provider) ||
		(OAUTH_SUBSCRIPTION_PROVIDER_IDS.has(provider) &&
			ctx.modelRegistry.isUsingOAuth(ctx.model))
	);
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

function parseCodexWindow(value: unknown): UsageWindow | undefined {
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

function parseOpenCodeGoUsage(payload: unknown): OpenCodeGoUsage | undefined {
	const usage = asObject(asObject(payload)?.usage);
	if (!usage) return undefined;
	const parseWindow = (value: unknown): UsageWindow | undefined => {
		const window = asObject(value);
		const usedPercent = asNumber(window?.percent);
		if (usedPercent === undefined) return undefined;
		const rawReset = window?.resetsAt;
		const parsedReset = typeof rawReset === "string" ? Date.parse(rawReset) : asNumber(rawReset);
		return {
			usedPercent,
			resetsAt: parsedReset === undefined || !Number.isFinite(parsedReset)
				? undefined
				: (parsedReset < 10_000_000_000 ? parsedReset : parsedReset / 1000),
		};
	};
	const result = {
		rolling: parseWindow(usage.rolling),
		weekly: parseWindow(usage.weekly),
		monthly: parseWindow(usage.monthly),
	};
	return result.rolling || result.weekly || result.monthly ? result : undefined;
}

function clampPercent(value: number): number {
	return Math.min(100, Math.max(0, value));
}

function formatRemainingPercent(window: UsageWindow): string {
	return `${Math.round(100 - clampPercent(window.usedPercent))}%`;
}

function formatRemainingTime(window: UsageWindow): string {
	if (!window.resetsAt) return "?";

	const ms = Math.max(0, window.resetsAt * 1000 - Date.now());
	const minutes = ms / 60_000;
	if (minutes < 60) return `${Math.round(minutes)}m`;

	const hours = minutes / 60;
	if (hours < 24) return `${formatOneDecimal(hours)}h`;
	return `${formatOneDecimal(hours / 24)}d`;
}

function formatOneDecimal(value: number): string {
	const rounded = Math.round(value * 10) / 10;
	return Number.isInteger(rounded) ? String(rounded) : rounded.toFixed(1);
}

function formatWindowDuration(seconds: number): string {
	const minutes = seconds / 60;
	if (minutes < 60) return `${formatOneDecimal(minutes)}m`;

	const hours = minutes / 60;
	if (hours < 24) return `${formatOneDecimal(hours)}h`;

	const days = hours / 24;
	if (days < 7) return `${formatOneDecimal(days)}d`;
	return `${formatOneDecimal(days / 7)}w`;
}

function formatCodexWindow(window: UsageWindow): string | undefined {
	if (!window.windowSeconds) return undefined;
	return `${formatWindowDuration(window.windowSeconds)} ${formatRemainingPercent(window)} ${formatRemainingTime(window)}`;
}

function formatCodexUsage(usage: CodexUsage): string {
	return [usage.primary, usage.secondary]
		.map((window) => (window ? formatCodexWindow(window) : undefined))
		.filter((window): window is string => window !== undefined)
		.join("  ");
}

function formatOpenCodeGoUsage(usage: OpenCodeGoUsage): string {
	return ([
		["5h", usage.rolling],
		["1w", usage.weekly],
		["1m", usage.monthly],
	] as const)
		.flatMap(([label, window]) => window
			? [`${label} ${formatRemainingPercent(window)} ${formatRemainingTime(window)}`]
			: [])
		.join("  ");
}

async function fetchProviderUsage(ctx: ExtensionContext, provider: UsageProvider): Promise<string> {
	const model = ctx.model;
	if (!model) return "";

	const auth = await ctx.modelRegistry.getApiKeyAndHeaders(model);
	if (!auth.ok) throw new Error(auth.error);

	const headers = new Headers();
	for (const [key, value] of Object.entries(auth.headers ?? {})) {
		if (value !== null) headers.set(key, value);
	}
	if (!headers.has("authorization")) {
		if (!auth.apiKey) return "";
		headers.set("Authorization", `Bearer ${auth.apiKey}`);
	}
	if (!headers.has("user-agent")) headers.set("User-Agent", "pi-simple-footer");

	const controller = new AbortController();
	const timeout = setTimeout(() => controller.abort(), USAGE_TIMEOUT_MS);
	try {
		const response = await fetch(USAGE_URLS[provider], {
			headers,
			signal: controller.signal,
		});
		if (!response.ok) return "";
		const payload: unknown = await response.json();
		if (provider === CODEX_PROVIDER_ID) {
			const usage = parseCodexUsage(payload);
			return usage ? formatCodexUsage(usage) : "";
		}
		const usage = parseOpenCodeGoUsage(payload);
		return usage ? formatOpenCodeGoUsage(usage) : "";
	} finally {
		clearTimeout(timeout);
	}
}

export default function (pi: ExtensionAPI) {
	let enabled = false;
	let providerUsage = "";
	let usageFetchedAt = 0;
	let usageFetching = false;
	let usageRequestId = 0;
	let usageTimer: ReturnType<typeof setTimeout> | undefined;
	let activeContext: ExtensionContext | undefined;
	let activeRender: (() => void) | undefined;

	const clearUsageTimer = () => {
		if (!usageTimer) return;
		clearTimeout(usageTimer);
		usageTimer = undefined;
	};

	const scheduleUsageRefresh = (ctx: ExtensionContext) => {
		clearUsageTimer();
		usageTimer = setTimeout(() => {
			usageTimer = undefined;
			if (!activeContext) return;
			refreshUsage(ctx, true);
		}, USAGE_TTL_MS);
		usageTimer.unref?.();
	};

	const refreshUsage = (ctx: ExtensionContext, force = false) => {
		if (!activeContext) return;
		const provider = usageProvider(ctx);
		if (!provider) {
			providerUsage = "";
			usageFetchedAt = 0;
			clearUsageTimer();
			return;
		}
		if (usageFetching) return;
		if (!force && Date.now() - usageFetchedAt < USAGE_TTL_MS) return;

		usageFetching = true;
		const requestId = ++usageRequestId;
		void fetchProviderUsage(ctx, provider)
			.then((usage) => {
				if (requestId !== usageRequestId) return;
				providerUsage = usage;
				usageFetchedAt = Date.now();
				activeRender?.();
			})
			.catch(() => {
				if (requestId !== usageRequestId) return;
				providerUsage = "";
				usageFetchedAt = Date.now();
				activeRender?.();
			})
			.finally(() => {
				if (requestId !== usageRequestId) return;
				usageFetching = false;
				scheduleUsageRefresh(ctx);
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
					refreshUsage(ctx);

					let cost = 0;
					if (!isUsingSubscription(ctx)) {
						for (const entry of ctx.sessionManager.getEntries()) {
							if (entry.type === "usage") {
								cost += entry.usage.cost.total;
							} else if (entry.type === "branch_summary" || entry.type === "compaction") {
								cost += entry.usage?.cost.total ?? 0;
							} else if (entry.type === "message" &&
								(entry.message.role === "assistant" || entry.message.role === "toolResult")) {
								cost += entry.message.usage?.cost.total ?? 0;
							}
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
					const contextUsage = ctx.getContextUsage();
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

					const statsParts = isUsingSubscription(ctx)
						? [contextStr]
						: [formatCost(cost), contextStr];
					let stats = statsParts.join(" ");
					if (providerUsage) stats += ` • ${providerUsage}`;

					// Left side: cwd • stats
					const leftText = `${cwd} • ${stats}`;
					const leftWidth = visibleWidth(leftText);

					// Right side: provider/model • thinking
					const modelName = ctx.model?.id || "no-model";
					const provider = ctx.model?.provider || "";
					let rightSide = provider ? `${provider}/${modelName}` : modelName;

					if (ctx.model?.reasoning) {
						const level = pi.getThinkingLevel();
						rightSide += level === "off" ? " • thinking off" : ` • ${level}`;
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
			if (ctx.mode !== "tui") return;
			enabled = !enabled;

			if (enabled) {
				activeContext = ctx;
				ctx.ui.setFooter(createFooter(ctx));
				refreshUsage(ctx, true);
				ctx.ui.notify("Simple footer enabled", "info");
			} else {
				activeContext = undefined;
				usageRequestId++;
				usageFetching = false;
				clearUsageTimer();
				ctx.ui.setFooter(undefined);
				ctx.ui.notify("Default footer restored", "info");
			}
		},
	});

	pi.on("model_select", (_event, ctx) => {
		if (!activeContext) return;
		providerUsage = "";
		usageFetchedAt = 0;
		usageRequestId++;
		usageFetching = false;
		clearUsageTimer();
		refreshUsage(ctx, true);
		activeRender?.();
	});

	pi.on("agent_end", (_event, ctx) => {
		if (!activeContext) return;
		refreshUsage(ctx, true);
	});

	pi.on("session_start", (_event, ctx) => {
		clearUsageTimer();
		usageRequestId++;
		usageFetching = false;
		providerUsage = "";
		usageFetchedAt = 0;
		if (ctx.mode !== "tui") {
			enabled = false;
			activeContext = undefined;
			return;
		}
		enabled = true;
		activeContext = ctx;
		ctx.ui.setFooter(createFooter(ctx));
		refreshUsage(ctx, true);
	});

	pi.on("session_shutdown", () => {
		activeContext = undefined;
		usageRequestId++;
		usageFetching = false;
		clearUsageTimer();
	});
}
