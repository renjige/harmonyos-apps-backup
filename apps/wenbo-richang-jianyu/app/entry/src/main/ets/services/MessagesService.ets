import { HttpClient } from './HttpClient'

export class MessageRow {
  id: string = ''
  title: string = ''
  body: string = ''
  read: boolean = false
}

class MessageWire {
  id: string = ''
  title: string = ''
  body: string = ''
  read: boolean = false
}

class MessageListPayload {
  list: MessageWire[] = []
}

export class MessagesService {
  static async loadMessages(): Promise<MessageRow[]> {
    const res = await HttpClient.get<MessageListPayload>('/messages')
    const out: MessageRow[] = []
    if (res.code !== 0 || res.data === undefined) {
      return out
    }
    for (const row of res.data.list) {
      const item = new MessageRow()
      item.id = row.id
      item.title = row.title
      item.body = row.body
      item.read = row.read
      out.push(item)
    }
    return out
  }
}
