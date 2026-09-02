/**
 * 上架合规开关：无《安全评估报告》时禁止 C 端生成式能力。
 * 手账拾意第一版不提供对话；「智慧回顾」仅为本地统计。
 */
export class FeatureFlags {
  static readonly LLM_ENABLED: boolean = false

  static llmEnabled(): boolean {
    return FeatureFlags.LLM_ENABLED
  }
}
