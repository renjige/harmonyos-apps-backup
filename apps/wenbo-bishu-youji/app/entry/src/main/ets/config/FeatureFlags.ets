/**
 * 上架合规开关：无《安全评估报告》时禁止 C 端生成式大模型对话。
 * 出行自测 = 问卷 + 规则匹配，不调用 /ai/chat。
 */
export class FeatureFlags {
  /** false = 方案 B：模板匹配；true 仅在取得安全评估报告后开启 */
  static readonly LLM_ENABLED: boolean = false

  static llmEnabled(): boolean {
    return FeatureFlags.LLM_ENABLED
  }
}
