import { MainTabPage } from './MainTabPage'
import { GewuDetailNav } from '../services/GewuDetailNav'

@Entry
@Component
struct Index {
  onBackPress(): boolean {
    const legal = AppStorage.get<string>('gewuLegalKind') ?? ''
    if (legal.length > 0) {
      AppStorage.setOrCreate('gewuLegalKind', '')
      return true
    }
    const editorId = AppStorage.get<string>('recordEditorId') ?? ''
    if (editorId.length > 0) {
      GewuDetailNav.close()
      return true
    }
    const recordId = AppStorage.get<string>('openRecordId') ?? ''
    if (recordId.length > 0) {
      GewuDetailNav.close()
      return true
    }
    const detailId = AppStorage.get<string>('openDetailId') ?? ''
    if (detailId.length > 0) {
      GewuDetailNav.close()
      return true
    }
    const practice = AppStorage.get<string>('practiceSheet') ?? ''
    if (practice.length > 0) {
      GewuDetailNav.closePractice()
      return true
    }
    const settingsOpen = AppStorage.get<boolean>('traceSettingsOpen') ?? false
    if (settingsOpen) {
      AppStorage.setOrCreate('traceSettingsOpen', false)
      AppStorage.setOrCreate('tabBarHidden', false)
      return true
    }
    return false
  }

  build() {
    Stack() {
      MainTabPage()
        .width('100%')
        .height('100%')
    }
    .width('100%')
    .height('100%')
  }
}
