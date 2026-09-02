import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { LifeToolEntry } from '../models/LifeHubModels'
import { LifeHubNav } from '../services/LifeHubNav'
import { MoodPage } from './MoodPage'
import { ReminderPage } from './ReminderPage'
import { TodoPage } from './TodoPage'
import { LifeCalendarPage } from './LifeCalendarPage'
import { TagManagePage } from './TagManagePage'
import { HabitPage } from './HabitPage'
import { PhotoTimelinePage } from './PhotoTimelinePage'
import { GoalPage } from './GoalPage'
import { LifeStatsPage } from './LifeStatsPage'
import { PlanPage } from './PlanPage'
import { AchievementPage } from './AchievementPage'
import { ActivityFeedPage } from './ActivityFeedPage'
import { TopicPage } from './TopicPage'
import { SearchHubPage } from './SearchHubPage'

@Component
export struct LifeHubHost {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('lifeHubRoute') route: string = ''
  onRequireAuth: () => void = () => {}
  private tools: LifeToolEntry[] = LifeHubNav.tools()

  build() {
    if (this.route === 'mood') {
      MoodPage({ onRequireAuth: (): void => this.onRequireAuth() })
    } else if (this.route === 'reminders') {
      ReminderPage({ onRequireAuth: (): void => this.onRequireAuth() })
    } else if (this.route === 'todos') {
      TodoPage({ onRequireAuth: (): void => this.onRequireAuth() })
    } else if (this.route === 'calendar') {
      LifeCalendarPage({ onRequireAuth: (): void => this.onRequireAuth() })
    } else if (this.route === 'tags') {
      TagManagePage({ onRequireAuth: (): void => this.onRequireAuth() })
    } else if (this.route === 'habits') {
      HabitPage({ onRequireAuth: (): void => this.onRequireAuth() })
    } else if (this.route === 'photos') {
      PhotoTimelinePage({ onRequireAuth: (): void => this.onRequireAuth() })
    } else if (this.route === 'goals') {
      GoalPage({ onRequireAuth: (): void => this.onRequireAuth() })
    } else     if (this.route === 'stats') {
      LifeStatsPage()
    } else if (this.route === 'plans') {
      PlanPage({ onRequireAuth: (): void => this.onRequireAuth() })
    } else if (this.route === 'achievements') {
      AchievementPage()
    } else if (this.route === 'activity') {
      ActivityFeedPage()
    } else if (this.route === 'topics') {
      TopicPage({ onRequireAuth: (): void => this.onRequireAuth() })
    } else if (this.route === 'search') {
      SearchHubPage()
    } else {
      this.MenuBody()
    }
  }

  @Builder
  MenuBody() {
    Column() {
      Row({ space: Theme.space.s2 }) {
        Column() {
          AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .rotate({ angle: 180 })
        .onClick((): void => { LifeHubNav.close() })
        Column({ space: 2 }) {
          Text('生活笺台')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          Text('计划、成就、专题与日常工具')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textSecondary)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })

      Scroll() {
        Column({ space: Theme.space.s3 }) {
          ForEach(this.tools, (t: LifeToolEntry) => {
            Column({ space: 4 }) {
              Text(t.title)
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colors().textPrimary)
                .width('100%')
              Text(t.subtitle)
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textSecondary)
                .width('100%')
            }
            .width('100%')
            .padding(Theme.space.s4)
            .alignItems(HorizontalAlign.Start)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.lg)
            .border({ width: 1, color: Theme.colors().strokeHairline })
            .onClick((): void => { LifeHubNav.open(t.id, true) })
          }, (t: LifeToolEntry) => t.id)
        }
        .width('100%')
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          bottom: Theme.space.s10
        })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
