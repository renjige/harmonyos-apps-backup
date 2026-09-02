/**
 * 上架合规开关：无《安全评估报告》时禁止 C 端生成式对话。
 * 出装检视 = 问卷 + 规则对照，不调用 /ai/chat。
 */
export class FeatureFlags {
  static readonly LLM_ENABLED: boolean = false

  static llmEnabled(): boolean {
    return FeatureFlags.LLM_ENABLED
  }
}
