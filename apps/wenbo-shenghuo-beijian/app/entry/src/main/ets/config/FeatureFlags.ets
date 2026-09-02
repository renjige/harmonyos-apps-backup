/**
 * 上架合规开关：无《安全评估报告》时禁止 C 端生成式对话。
 * 生活备笺交付「智慧整理」（本地关键词）+ 生活回顾（规则统计），不调用 /ai/chat。
 */
export class FeatureFlags {
  /** false = 方案 B；true 仅在取得安全评估报告后开启 */
  static readonly LLM_ENABLED: boolean = false

  static llmEnabled(): boolean {
    return FeatureFlags.LLM_ENABLED
  }
}
