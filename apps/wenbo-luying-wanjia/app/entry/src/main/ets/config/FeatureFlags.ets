/**
 * 上架合规开关：无《安全评估报告》时禁止 C 端生成式对话。
 * 智慧清单 = 问卷 + 规则匹配装备模板，不调用 /ai/chat。
 */
export class FeatureFlags {
  /** false = 方案 B：模板诊断；true 仅在取得安全评估报告后开启 */
  static readonly LLM_ENABLED: boolean = false

  static llmEnabled(): boolean {
    return FeatureFlags.LLM_ENABLED
  }
}
