import QtQuick
import Quickshell
import Quickshell.Io

Scope {
	id: root

	required property var row
	required property string imageDirectory
	required property var linkCache
	property bool thumbnailOnly: false
	readonly property string cacheKey: thumbnailOnly ? "icon" : "link"
	readonly property var cachedLink: row.kind === "link" && !row.sensitive && linkCache[row.url]
		? linkCache[row.url][cacheKey] : null
	readonly property string imagePath: `${imageDirectory}/${row.id}.${row.extension}`
	property string text: row.sensitive ? "sensitive clipboard item\n\npress enter to restore it for 10 minutes"
		: row.kind === "link" ? row.url : ""
	property url image: thumbnailOnly && cachedLink ? cachedLink
		: !row.sensitive && row.kind === "file" && row.fileType === "image"
			? "file://" + row.filePath.split("/").map(encodeURIComponent).join("/") : ""
	property var link: !thumbnailOnly && cachedLink ? cachedLink : null

	function cacheLink(value): void {
		if (!linkCache[row.url]) {
			const urls = Object.keys(linkCache);
			if (urls.length >= 100)
				delete linkCache[urls[0]];
			linkCache[row.url] = {};
		}
		linkCache[row.url][cacheKey] = value;
	}

	Process {
		running: !root.row.sensitive && !root.cachedLink && (root.row.kind === "image" || root.row.kind === "link"
			|| (!root.thumbnailOnly && !(root.row.kind === "file" && root.row.fileType === "image")))
		command: root.row.kind === "image"
			? [`${Quickshell.shellDir}/scripts/clipboard-image-cache`, root.row.id, root.row.previewMime, root.imagePath]
			: root.row.kind === "link"
				? [`${Quickshell.shellDir}/scripts/link-preview`, ...(root.thumbnailOnly ? ["--favicon"] : []), root.row.url]
				: ["rift", "read", root.row.id, "--mime", root.row.previewMime]
		stdout: StdioCollector { id: output }
		onExited: exitCode => {
			if (exitCode !== 0)
				return;
			if (root.row.kind === "image") {
				root.image = `file://${root.imagePath}`;
			} else if (root.row.kind === "link" && root.thumbnailOnly) {
				root.image = output.text.trim();
				if (root.image.toString() !== "")
					root.cacheLink(root.image.toString());
			} else if (root.row.kind === "link") {
				try {
					root.link = JSON.parse(output.text);
					root.cacheLink(root.link);
				} catch (error) {
					console.warn("could not parse link preview", error);
				}
			} else {
				root.text = output.text;
			}
		}
	}
}
