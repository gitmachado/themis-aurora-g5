const TYPE_TO_EMOJI = {
  feat: "🌟",
  fix: "🐛",
  docs: "📝",
  style: "🎨",
  refactor: "♻️",
  perf: "⚡",
  test: "✅",
  chore: "🔧",
  ci: "🚀",
  build: "📦",
  revert: "⏪",
};

const TYPE_LIST = Object.keys(TYPE_TO_EMOJI).join("|");
const EMOJI_PATTERN = Object.values(TYPE_TO_EMOJI)
  .map((emoji) => emoji.replace(/[.*+?^${}()|[\]\\]/g, "\\$&"))
  .join("|");
const COMMIT_PATTERN = new RegExp(
  `^(${EMOJI_PATTERN})(${TYPE_LIST}): ([A-Z0-9]+-\\d+) (.+)$`,
  "u"
);

module.exports = {
  plugins: [
    {
      rules: {
        "header-match-team-pattern": (parsed) => {
          const header = parsed.header || "";
          const match = header.match(COMMIT_PATTERN);

          if (!match) {
            return [
              false,
              "commit must follow '<emoji><type>: <TICKET> <description>', e.g. '🌟feat: TIC-45 create auth routes'",
            ];
          }

          const [, emoji, type] = match;
          const expectedEmoji = TYPE_TO_EMOJI[type];

          if (emoji !== expectedEmoji) {
            return [
              false,
              `type '${type}' must use emoji '${expectedEmoji}'`,
            ];
          }

          return [true];
        },
      },
    },
  ],
  rules: {
    "header-match-team-pattern": [2, "always"],
  },
};
