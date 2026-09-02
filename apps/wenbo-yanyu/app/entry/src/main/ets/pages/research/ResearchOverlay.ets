import { NoteListPage } from './NoteListPage'
import { NoteEditPage } from './NoteEditPage'
import { NoteDetailPane } from './NoteDetailPane'
import { TopicDetailPage, TopicListPage } from './TopicListPage'
import { TagManagePage } from './TagManagePage'
import { SparkListPage } from './SparkListPage'
import { TimelinePage } from './TimelinePage'
import { CardListPage } from './CardListPage'
import { ReadingListPage } from './ReadingListPage'
import { PlanListPage } from './PlanListPage'
import { CollectionPage } from './CollectionPage'
import { DailyThinkPage } from './DailyThinkPage'
import { SearchPage } from './SearchPage'
import { StatsPage } from './StatsPage'

@Component
export struct ResearchOverlay {
  @StorageLink('researchPanel') @Watch('onPanelChange') panel: string = ''

  onPanelChange(): void {
    if (this.panel === 'stats') {
      AppStorage.setOrCreate('researchRefresh', Date.now())
    }
  }

  build() {
    Stack() {
      if (this.panel === 'notes') {
        NoteListPage()
      } else if (this.panel === 'note-edit') {
        NoteEditPage()
      } else if (this.panel === 'note-detail') {
        NoteDetailPane()
      } else if (this.panel === 'topics') {
        TopicListPage()
      } else if (this.panel === 'topic-detail') {
        TopicDetailPage()
      } else if (this.panel === 'tags') {
        TagManagePage()
      } else if (this.panel === 'sparks') {
        SparkListPage()
      } else if (this.panel === 'timeline') {
        TimelinePage()
      } else if (this.panel === 'cards') {
        CardListPage()
      } else if (this.panel === 'readings') {
        ReadingListPage()
      } else if (this.panel === 'plans') {
        PlanListPage()
      } else if (this.panel === 'collections') {
        CollectionPage()
      } else if (this.panel === 'daily') {
        DailyThinkPage()
      } else if (this.panel === 'search') {
        SearchPage()
      } else if (this.panel === 'stats') {
        StatsPage()
      }
    }
    .width('100%')
    .height('100%')
  }
}
