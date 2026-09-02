/**
 * 上架合规开关：无《安全评估报告》时禁止 C 端生成式对话。
 * 本周回顾 = 规则模板文案，不调用大模型。
 */
export class FeatureFlags {
  static readonly LLM_ENABLED: boolean = false

  static llmEnabled(): boolean {
    return FeatureFlags.LLM_ENABLED
  }
}
