/**
 * 上架合规开关：无《安全评估报告》时禁止 C 端生成式对话。
 * 学诗匹配 = 问卷 + 规则模板，不调用云端大模型。
 */
export class FeatureFlags {
  static readonly LLM_ENABLED: boolean = false

  static llmEnabled(): boolean {
    return FeatureFlags.LLM_ENABLED
  }
}
