/**
 * 格物集为纯本地应用，不涉及生成式 LLM。
 */
export class FeatureFlags {
  static readonly LLM_ENABLED: boolean = false

  static llmEnabled(): boolean {
    return FeatureFlags.LLM_ENABLED
  }
}
