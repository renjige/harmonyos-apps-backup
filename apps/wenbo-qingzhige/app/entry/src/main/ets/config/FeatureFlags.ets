/**
 * 上架合规开关：无《安全评估报告》时禁止 C 端生成式对话。
 * 轻知阁交付「智能分类」（本地关键词）+ 复习队列（规则），不调用 /ai/chat。
 * 界面禁止出现「AI」字样。
 */
export class FeatureFlags {
  static readonly LLM_ENABLED: boolean = false

  static llmEnabled(): boolean {
    return FeatureFlags.LLM_ENABLED
  }
}
