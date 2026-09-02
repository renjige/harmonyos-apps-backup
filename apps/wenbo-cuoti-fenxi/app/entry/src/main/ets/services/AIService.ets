import {
  AiAnalyzeRequest,
  AiAnalyzeResponse,
  AiChatRequest,
  AiChatResponse,
  AiGenerateRequest,
  AiGenerateResponse
} from '../models/ApiModels'
import { FeatureFlags } from '../config/FeatureFlags'
import { HttpClient } from './HttpClient'

/**
 * 生成式 LLM 网关。上架默认关闭（FeatureFlags.LLM_ENABLED=false）。
 * 学情诊断请使用 DiagnoseService（问卷模板）。
 */
export class AIService {
  static lastError: string = ''

  static async chat(prompt: string, context?: string): Promise<string> {
    AIService.lastError = ''
    if (!FeatureFlags.llmEnabled()) {
      AIService.lastError = '本版本未启用生成式对话，请使用「学情诊断」问卷'
      throw new Error(AIService.lastError)
    }
    const body = new AiChatRequest()
    body.prompt = prompt
    body.context = context ?? ''
    const res = await HttpClient.post<AiChatResponse>('/ai/chat', body)
    if (res.code !== 0 || res.data === undefined) {
      AIService.lastError = res.message.length > 0 ? res.message : HttpClient.lastError
      if (AIService.lastError.length === 0) {
        AIService.lastError = 'AI 问答失败'
      }
      throw new Error(AIService.lastError)
    }
    const reply = res.data.reply
    if (reply.length === 0) {
      AIService.lastError = 'AI 返回为空'
      throw new Error(AIService.lastError)
    }
    return reply
  }

  static async analyze(payload: string, type: string): Promise<AiAnalyzeResponse> {
    if (!FeatureFlags.llmEnabled()) {
      throw new Error('本版本未启用生成式 AI')
    }
    const body = new AiAnalyzeRequest()
    body.payload = payload
    body.type = type
    const res = await HttpClient.post<AiAnalyzeResponse>('/ai/analyze', body)
    if (res.code !== 0 || res.data === undefined) {
      throw new Error(res.message.length > 0 ? res.message : 'AI 分析失败')
    }
    return res.data
  }

  static async generate(template: string, variables: string): Promise<string> {
    if (!FeatureFlags.llmEnabled()) {
      throw new Error('本版本未启用生成式 AI')
    }
    const body = new AiGenerateRequest()
    body.template = template
    body.variables = variables
    const res = await HttpClient.post<AiGenerateResponse>('/ai/generate', body)
    if (res.code !== 0 || res.data === undefined) {
      throw new Error(res.message.length > 0 ? res.message : 'AI 生成失败')
    }
    return res.data.content
  }
}
