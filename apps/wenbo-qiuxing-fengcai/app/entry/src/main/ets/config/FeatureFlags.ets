/**
 * 上架合规开关：无《安全评估报告》时禁止 C 端生成式 LLM。
 * 球星风采不提供生成式对话，仅资料浏览与提醒。
 */
export class FeatureFlags {
  static readonly LLM_ENABLED: boolean = false

  static llmEnabled(): boolean {
    return FeatureFlags.LLM_ENABLED
  }
}
