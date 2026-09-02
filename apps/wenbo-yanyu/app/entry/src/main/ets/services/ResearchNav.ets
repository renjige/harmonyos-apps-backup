import { AppRefresh } from './AppRefresh'

/** 研究工作台 Overlay 路由 */
export class ResearchNav {
  static open(panel: string, itemId: string = ''): void {
    AppStorage.setOrCreate('tabBarHidden', true)
    AppStorage.setOrCreate('researchItemId', itemId)
    AppStorage.setOrCreate('researchPanel', panel)
    AppStorage.setOrCreate('researchRefresh', Date.now())
  }

  static close(): void {
    AppStorage.setOrCreate('researchPanel', '')
    AppStorage.setOrCreate('researchItemId', '')
    AppStorage.setOrCreate('tabBarHidden', false)
    AppRefresh.bumpResearch()
  }

  static openNoteEditor(id: string, topicId: string = ''): void {
    AppStorage.setOrCreate('researchDraftTopicId', topicId)
    ResearchNav.open('note-edit', id)
  }

  static openNoteDetail(id: string): void {
    ResearchNav.open('note-detail', id)
  }

  static openTopicDetail(id: string): void {
    ResearchNav.open('topic-detail', id)
  }
}
