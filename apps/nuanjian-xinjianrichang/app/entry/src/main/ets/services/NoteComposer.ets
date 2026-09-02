import { NoteItem } from '../models/NoteModels'
import { HeartNoteStore } from './HeartNoteStore'
import { HeartNoteMedia } from './HeartNoteMedia'
import { NoteDateUtil } from './NoteDateUtil'

/** 写心笺草稿装配（页面只负责绑定输入） */
export class NoteComposer {
  static blank(mood: string): NoteItem {
    const item = new NoteItem()
    item.mood = mood.length > 0 ? mood : 'calm'
    return item
  }

  static fromExisting(id: string): NoteItem | undefined {
    return HeartNoteStore.find(id)
  }

  static toItem(
    editingId: string,
    title: string,
    body: string,
    mood: string,
    tagsCsv: string,
    photo0: string,
    photo1: string,
    photo2: string
  ): NoteItem {
    const now = new Date()
    const item = new NoteItem()
    item.id = editingId.length > 0 ? editingId : `n_${now.getTime()}`
    item.title = title.trim().length > 0 ? title.trim() : '今天的小确幸'
    item.body = body.trim()
    item.mood = mood
    item.tagsCsv = tagsCsv
    item.photoUri0 = photo0
    item.photoUri1 = photo1
    item.photoUri2 = photo2
    item.noteDate = NoteDateUtil.todayIso()
    item.period = NoteDateUtil.periodOf(now)
    item.coverKey = HeartNoteMedia.coverForMood(mood)
    item.updatedAt = now.getTime()
    if (editingId.length > 0) {
      const old = HeartNoteStore.find(editingId)
      item.createdAt = old !== undefined ? old.createdAt : now.getTime()
      item.noteDate = old !== undefined ? old.noteDate : item.noteDate
      item.period = old !== undefined ? old.period : item.period
    } else {
      item.createdAt = now.getTime()
    }
    return item
  }

  static toggleTag(current: string[], tag: string): string[] {
    const next: string[] = []
    let removed = false
    for (const t of current) {
      if (t === tag) {
        removed = true
      } else {
        next.push(t)
      }
    }
    if (!removed) {
      next.push(tag)
    }
    return next
  }

  static addChoice(choices: string[], tag: string): string[] {
    for (const c of choices) {
      if (c === tag) {
        return choices
      }
    }
    const next: string[] = []
    for (const c of choices) {
      next.push(c)
    }
    next.push(tag)
    return next
  }

  static async saveDraft(item: NoteItem): Promise<void> {
    await HeartNoteStore.save(item)
    await HeartNoteStore.setTodayMood(item.mood, item.noteDate)
  }
}
