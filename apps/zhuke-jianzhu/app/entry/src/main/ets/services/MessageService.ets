import { HttpClient } from './HttpClient'
import { MessageSubmitResult } from './ContentCache'
import { ApiResponse } from '../models/ApiModels'

/** 留言与反馈 — 提交至 SaaS 后台 */
export class MessageService {
  static async submitContact(name: string, phone: string, content: string): Promise<boolean> {
    const body = new ContactMessageBody()
    body.name = name
    body.phone = phone
    body.content = content
    body.type = 'contact'
    const res = await HttpClient.post<MessageSubmitResult>('/content/messages', body)
    return MessageService.isSuccess(res)
  }

  static async submitFeedback(content: string, contact: string): Promise<boolean> {
    const body = new FeedbackMessageBody()
    body.content = content
    body.contact = contact
    const res = await HttpClient.post<MessageSubmitResult>('/content/feedback', body)
    return MessageService.isSuccess(res)
  }

  private static isSuccess(res: ApiResponse<MessageSubmitResult>): boolean {
    return res.code === 0 && res.data !== undefined
  }
}

class ContactMessageBody {
  name: string = ''
  phone: string = ''
  content: string = ''
  type: string = 'contact'
}

class FeedbackMessageBody {
  content: string = ''
  contact: string = ''
}
