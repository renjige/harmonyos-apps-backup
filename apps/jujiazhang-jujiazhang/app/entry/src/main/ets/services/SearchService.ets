import { SearchHit } from '../models/JujiaModels'
import { TaskLocalStore } from './TaskLocalStore'
import { JujiaLocalStore } from './JujiaLocalStore'
import { KnowledgeService } from './KnowledgeService'

export class SearchService {
  static match(keyword: string, typeFilter: string = 'all'): SearchHit[] {
    const q = keyword.trim().toLowerCase()
    if (q.length === 0) {
      return []
    }
    const out: SearchHit[] = []
    if (typeFilter === 'all' || typeFilter === 'task') {
      for (const row of TaskLocalStore.tasks()) {
        if (SearchService.contains(row.title, q) || SearchService.contains(row.category, q)) {
          const hit = new SearchHit()
          hit.entityType = 'task'
          hit.entityId = row.id
          hit.title = row.title
          hit.subtitle = `${row.date} · ${row.category}`
          hit.tag = row.completed ? '已完成' : '待办'
          out.push(hit)
        }
      }
    }
    if (typeFilter === 'all' || typeFilter === 'item') {
      for (const row of JujiaLocalStore.items()) {
        if (SearchService.contains(row.name, q) || SearchService.contains(row.room, q)) {
          const hit = new SearchHit()
          hit.entityType = 'item'
          hit.entityId = row.id
          hit.title = row.name
          hit.subtitle = `${row.category} · ${row.room}`
          hit.tag = row.expiryLabel()
          out.push(hit)
        }
      }
    }
    if (typeFilter === 'all' || typeFilter === 'memo') {
      for (const row of JujiaLocalStore.memos()) {
        if (SearchService.contains(row.title, q) || SearchService.contains(row.body, q)) {
          const hit = new SearchHit()
          hit.entityType = 'memo'
          hit.entityId = row.id
          hit.title = row.title
          hit.subtitle = row.tag
          hit.tag = '备忘'
          out.push(hit)
        }
      }
    }
    if (typeFilter === 'all' || typeFilter === 'checklist') {
      for (const row of JujiaLocalStore.checklists()) {
        if (SearchService.contains(row.title, q) || SearchService.contains(row.kind, q)) {
          const hit = new SearchHit()
          hit.entityType = 'checklist'
          hit.entityId = row.id
          hit.title = row.title
          hit.subtitle = row.progressLabel()
          hit.tag = row.kind
          out.push(hit)
        }
      }
    }
    if (typeFilter === 'all' || typeFilter === 'diary') {
      for (const row of JujiaLocalStore.diaries()) {
        if (SearchService.contains(row.title, q) || SearchService.contains(row.body, q)) {
          const hit = new SearchHit()
          hit.entityType = 'diary'
          hit.entityId = row.id
          hit.title = row.title
          hit.subtitle = row.mood
          hit.tag = '日记'
          out.push(hit)
        }
      }
    }
    if (typeFilter === 'all' || typeFilter === 'tip') {
      for (const row of KnowledgeService.articles()) {
        if (SearchService.contains(row.title, q) || SearchService.contains(row.summary, q)) {
          const hit = new SearchHit()
          hit.entityType = 'tip'
          hit.entityId = row.id
          hit.title = row.title
          hit.subtitle = row.category
          hit.tag = '技巧'
          out.push(hit)
        }
      }
    }
    return out
  }

  private static contains(text: string, q: string): boolean {
    return text.toLowerCase().indexOf(q) >= 0
  }
}
