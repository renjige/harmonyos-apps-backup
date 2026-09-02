import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { AppError } from '../components/design-system/AppError'
import { ProjectCard } from '../components/quality/ProjectCard'
import { TodayStatsCard } from '../components/quality/TodayStatsCard'
import { ProjectItem } from '../models/QualityModels'
import { QualityService } from '../services/QualityService'
import { QualityNav } from '../services/QualityNav'
import { QualityStatsBus } from '../services/QualityStatsBus'

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop appName: string = '筑科质量巡查'
  @Prop tagline: string = '让每一次巡查，都有迹可循'
  @StorageLink('qualityTick') listToken: number = 0
  @State loading: boolean = false
  @State errorText: string = ''

  aboutToAppear(): void {
    QualityStatsBus.publish()
    void this.refresh()
  }

  private hasData(): boolean {
    const _keep = this.listToken
    return QualityService.projects().length > 0
      || QualityService.inspections().length > 0
      || QualityService.issues().length > 0
  }

  private recentProjects(): ProjectItem[] {
    const _keep = this.listToken
    const all = QualityService.projects()
    const out: ProjectItem[] = []
    for (const row of all) {
      if (out.length < 3) {
        out.push(row)
      }
    }
    return out
  }

  private async refresh(): Promise<void> {
    this.loading = true
    this.errorText = ''
    try {
      await QualityService.refreshRemote()
    } catch {
      this.errorText = '同步未完成，已显示本机记录'
    }
    this.loading = false
    QualityStatsBus.publish()
  }

  build() {
    Column() {
      Row() {
        Column({ space: 4 }) {
          Text(this.appName)
            .fontSize(Theme.type.title1)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          Text(this.tagline)
            .fontSize(Theme.type.footnote)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        Column() {
          AppIcon({ name: 'message', iconSize: Theme.icon.lg, color: Theme.colors().textPrimary })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .onClick(() => QualityNav.open('messages'))
      }
      .width('100%')
      .padding({ left: 20, right: 16, top: 16, bottom: 8 })

      if (this.loading && !this.hasData()) {
        AppLoading({ label: '正在加载巡查数据' })
      } else if (this.errorText.length > 0 && !this.hasData()) {
        AppError({
          title: '加载失败',
          message: this.errorText,
          retryLabel: '重试',
          onRetry: (): void => { void this.refresh() }
        })
      } else if (!this.hasData()) {
        AppEmpty({
          title: '开始第一次质量巡查',
          description: '记录每一次巡查，发现问题及时跟进。',
          actionLabel: '开始巡查',
          onAction: () => QualityNav.open('start')
        })
          .layoutWeight(1)
      } else {
        Scroll() {
          Column({ space: 16 }) {
            TodayStatsCard()
            this.quickActions()
            Text('最近项目')
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            ForEach(this.recentProjects(), (p: ProjectItem) => {
              ProjectCard({
                item: p,
                refreshToken: this.listToken,
                onOpen: (id: string) => QualityNav.open('project', id)
              })
            }, (p: ProjectItem) => `${p.id}_${this.listToken}`)
          }
          .padding({ left: 16, right: 16, bottom: 32 })
        }
        .layoutWeight(1)
        .align(Alignment.Top)
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }

  @Builder
  quickActions() {
    Column({ space: 10 }) {
      AppButton({
        label: '开始巡查',
        onTap: () => QualityNav.open('start')
      })
      Row({ space: 8 }) {
        Column() {
          AppButton({
            label: '新增问题',
            variant: 'secondary',
            onTap: () => QualityNav.open('newIssue')
          })
        }
        .layoutWeight(1)
        Column() {
          AppButton({
            label: '整改跟进',
            variant: 'secondary',
            onTap: () => {
              QualityNav.setIssueFilter('整改中')
              QualityNav.setTab(2)
            }
          })
        }
        .layoutWeight(1)
        Column() {
          AppButton({
            label: '巡查记录',
            variant: 'secondary',
            onTap: () => QualityNav.setTab(1)
          })
        }
        .layoutWeight(1)
      }
      .width('100%')
    }
    .width('100%')
  }
}
