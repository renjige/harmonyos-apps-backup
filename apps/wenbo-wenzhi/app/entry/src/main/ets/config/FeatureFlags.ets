/**
 * 上架合规：无安全评估报告时禁止 C 端生成式对话。
 * 问知交付「智慧问答」（知识库规则匹配）+ 求知偏好问卷，不调用 /ai/chat。
 * 界面禁止出现「AI」字样。
 */
export class FeatureFlags {
  static readonly LLM_ENABLED: boolean = false

  static llmEnabled(): boolean {
    return FeatureFlags.LLM_ENABLED
  }
}
