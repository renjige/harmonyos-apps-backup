import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { AppIcon } from '../components/design-system/AppIcon'
import { TimelineEvent } from '../models/InspirationModels'
import { InspirationBizService } from '../services/InspirationBizService'
import { InspirationDetailNav } from '../services/InspirationDetailNav'
import { AuthService } from '../services/AuthService'

@Component
export struct TimelinePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  onClose: () => void = () => {}
  onRequireAuth: () => void = () => {}
  @State events: TimelineEvent[] = []
  @State loading: boolean = true
  @StorageLink('currentUsername') currentUsername: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    if (AuthService.isLoggedIn()) {
      this.events = await InspirationBizService.loadTimeline(this.currentUsername, 50)
    } else {
      this.events = []
    }
    this.loading = false
  }

  private kindLabel(kind: string): string {
    if (kind === 'inspiration') {
      return '灵感'
    }
    if (kind === 'board') {
      return '画板'
    }
    if (kind === 'plan') {
      return '计划'
    }
    if (kind === 'favorite') {
      return '收藏'
    }
    if (kind === 'checkin') {
      return '打卡'
    }
    return '动态'
  }

  private openEvent(ev: TimelineEvent): void {
    if (ev.kind === 'inspiration') {
      InspirationDetailNav.openInspiration(ev.entityId)
    } else if (ev.kind === 'board') {
      InspirationDetailNav.openBoard(ev.entityId)
    } else if (ev.kind === 'plan') {
      InspirationDetailNav.openPlan(ev.entityId)
    }
  }

  build() {
    Column() {
      Row({ space: Theme.space.s2 }) {
        Column() {
          AppIcon({ name: 'chevron', iconSize: Theme.icon.md })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .rotate({ angle: 180 })
        .onClick((): void => { this.onClose() })
        Text('创作时间轴')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })

      if (this.loading) {
        AppLoading({ label: '加载时间轴…' }).layoutWeight(1)
      } else if (!AuthService.isLoggedIn()) {
        AppEmpty({
          title: '登录后查看时间轴',
          description: '你的灵感、画板、计划与打卡将按时间串联',
          actionLabel: '去登录',
          onAction: (): void => { this.onRequireAuth() }
        }).layoutWeight(1)
      } else if (this.events.length === 0) {
        AppEmpty({
          title: '还没有创作动态',
          description: '记录灵感、更新画板或推进计划后，这里会出现你的成长轨迹'
        }).layoutWeight(1)
      } else {
        List() {
          ForEach(this.events, (ev: TimelineEvent) => {
            ListItem() {
              Row({ space: Theme.space.s3 }) {
                Column({ space: 4 }) {
                  Text(ev.date)
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().textTertiary)
                  Text(this.kindLabel(ev.kind))
                    .fontSize(Theme.type.overline)
                    .fontColor(Theme.colors().brandPrimary)
                }
                .width(72)
                Column({ space: 4 }) {
                  Text(ev.title)
                    .fontSize(Theme.type.subhead)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(Theme.colors().textPrimary)
                    .width('100%')
                  if (ev.summary.length > 0) {
                    Text(ev.summary)
                      .fontSize(Theme.type.caption)
                      .fontColor(Theme.colors().textSecondary)
                      .width('100%')
                      .maxLines(2)
                  }
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
              }
              .width('100%')
              .padding(Theme.space.s4)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.lg)
              .border({ width: 1, color: Theme.colors().strokeHairline })
              .onClick((): void => { this.openEvent(ev) })
            }
            .padding({
              left: Theme.space.pageX,
              right: Theme.space.pageX,
              bottom: Theme.space.s3
            })
          }, (ev: TimelineEvent) => `${ev.kind}_${ev.entityId}_${ev.date}`)
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }
}
