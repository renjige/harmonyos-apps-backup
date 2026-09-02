import { FieldStore } from './FieldStore'

const KEY_OPEN_DETAIL = 'openDetailId'
const KEY_DETAIL_TICK = 'detailRefreshToken'
const KEY_RECORD_ID = 'openRecordId'
const KEY_EDITOR_ID = 'recordEditorId'
const KEY_PRACTICE = 'practiceSheet'
const KEY_FOCUS = 'practiceFocusId'

export class GewuDetailNav {
  static open(id: string): void {
    AppStorage.setOrCreate(KEY_RECORD_ID, '')
    AppStorage.setOrCreate(KEY_EDITOR_ID, '')
    AppStorage.setOrCreate(KEY_OPEN_DETAIL, id)
    AppStorage.setOrCreate('tabBarHidden', true)
    const tick = AppStorage.get<number>(KEY_DETAIL_TICK) ?? 0
    AppStorage.setOrCreate(KEY_DETAIL_TICK, tick + 1)
    void FieldStore.touchBrowse(id)
  }

  static openRecord(id: string): void {
    AppStorage.setOrCreate(KEY_OPEN_DETAIL, '')
    AppStorage.setOrCreate(KEY_EDITOR_ID, '')
    AppStorage.setOrCreate(KEY_RECORD_ID, id)
    AppStorage.setOrCreate('tabBarHidden', true)
    const tick = AppStorage.get<number>(KEY_DETAIL_TICK) ?? 0
    AppStorage.setOrCreate(KEY_DETAIL_TICK, tick + 1)
  }

  static openEditor(id: string): void {
    AppStorage.setOrCreate(KEY_OPEN_DETAIL, '')
    AppStorage.setOrCreate(KEY_RECORD_ID, '')
    AppStorage.setOrCreate(KEY_EDITOR_ID, id.length > 0 ? id : 'new')
    AppStorage.setOrCreate('tabBarHidden', true)
    const tick = AppStorage.get<number>(KEY_DETAIL_TICK) ?? 0
    AppStorage.setOrCreate(KEY_DETAIL_TICK, tick + 1)
  }

  static seedAndEdit(title: string, atlas: string, cover: string, subject: string): void {
    AppStorage.setOrCreate('recordSeedTitle', title)
    AppStorage.setOrCreate('recordSeedAtlas', atlas)
    AppStorage.setOrCreate('recordSeedCover', cover)
    AppStorage.setOrCreate('recordSubjectId', subject)
    GewuDetailNav.openEditor('new')
  }

  static close(): void {
    AppStorage.setOrCreate(KEY_OPEN_DETAIL, '')
    AppStorage.setOrCreate(KEY_RECORD_ID, '')
    AppStorage.setOrCreate(KEY_EDITOR_ID, '')
    AppStorage.setOrCreate('tabBarHidden', false)
    const tick = AppStorage.get<number>(KEY_DETAIL_TICK) ?? 0
    AppStorage.setOrCreate(KEY_DETAIL_TICK, tick + 1)
  }

  static openPractice(sheet: string, id: string): void {
    AppStorage.setOrCreate(KEY_PRACTICE, sheet)
    AppStorage.setOrCreate(KEY_FOCUS, id)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closePractice(): void {
    AppStorage.setOrCreate(KEY_PRACTICE, '')
    AppStorage.setOrCreate(KEY_FOCUS, '')
    const editor = AppStorage.get<string>(KEY_EDITOR_ID) ?? ''
    const rec = AppStorage.get<string>(KEY_RECORD_ID) ?? ''
    const det = AppStorage.get<string>(KEY_OPEN_DETAIL) ?? ''
    if (editor.length === 0 && rec.length === 0 && det.length === 0) {
      AppStorage.setOrCreate('tabBarHidden', false)
    }
  }

  static currentId(): string {
    const v = AppStorage.get<string>(KEY_OPEN_DETAIL)
    if (v === undefined || v === null) {
      return ''
    }
    return v
  }
}
