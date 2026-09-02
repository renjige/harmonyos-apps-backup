/**
 * 上架合规开关：无《安全评估报告》时禁止 C 端生成式 LLM。
 */
export class FeatureFlags {
  /** false = 方案 B：规则回顾；true 仅在取得安全评估报告后开启 */
  static readonly LLM_ENABLED: boolean = false

  static llmEnabled(): boolean {
    return FeatureFlags.LLM_ENABLED
  }
}
