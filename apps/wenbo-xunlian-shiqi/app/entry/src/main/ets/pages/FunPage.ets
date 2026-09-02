import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { SolidButton } from '../components/design-system/SolidButton'
import { FunQuest, FunQuestProgress } from '../models/TrainingModels'
import { FunQuestStore } from '../services/FunQuestStore'
import { FunQuestService } from '../services/FunQuestService'
import { TrainingDetailNav } from '../services/TrainingDetailNav'
import { PracticeNav } from '../services/PracticeNav'

@Component
export struct FunPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('dataEpoch') @Watch('onDataEpoch') dataEpoch: number = 0
  @Prop @Watch('onTok') refreshToken: number = 0
  @State quests: FunQuest[] = []
  onCreateQuest: () => void = () => {}
  onOpenRecap: () => void = () => {}

  aboutToAppear(): void {
    this.reload()
  }

  onDataEpoch(): void {
    this.reload()
  }

  onTok(): void {
    this.reload()
  }

  private reload(): void {
    this.quests = FunQuestStore.list()
  }

  private progressOf(q: FunQuest): FunQuestProgress {
    return FunQuestService.progress(q)
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s5 }) {
        this.Hero()
        Column() {
          SolidButton({
            label: '新建本周拾趣挑战',
            tone: 'primary',
            onTap: (): void => { this.onCreateQuest() }
          })
        }
        .width('100%')
        .onClick((): void => { this.onCreateQuest() })
        Column() {
          SolidButton({
            label: '做一份本周训练复盘',
            tone: 'secondary',
            onTap: (): void => { this.onOpenRecap() }
          })
        }
        .width('100%')
        .onClick((): void => { this.onOpenRecap() })

        Text('习惯工坊')
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')
        this.HubRow('趣味训练计划', '7 天拉伸 / 30 天基础 / 周末计划', 'plan')
        this.HubRow('动作收藏', '热身 · 力量 · 柔韧 · 放松', 'move')
        this.HubRow('训练清单', '训练前热身，训练后拉伸', 'check')
        this.HubRow('训练目标', '手动更新 12/20 进度', 'goal')
        this.HubRow('知识卡片', '自己整理的动作要点', 'card')

        Text('我的挑战')
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')

        if (this.quests.length === 0) {
          AppEmpty({
            title: '还没有拾趣挑战',
            description: '把「本周三次晨光跑」写成挑战，训练记录会自动计入进度',
            actionLabel: '立即创建',
            onAction: (): void => { this.onCreateQuest() }
          })
        } else {
          ForEach(this.quests, (q: FunQuest) => {
            this.QuestCard(q)
          }, (q: FunQuest) => q.id)
        }
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s6, bottom: Theme.space.s10 + 88 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
    .edgeEffect(EdgeEffect.Spring)
  }

  @Builder
  Hero() {
    Stack({ alignContent: Alignment.BottomStart }) {
      Image($r('app.media.fun_quest_bg'))
        .width('100%')
        .height(180)
        .objectFit(ImageFit.Cover)
        .borderRadius(Theme.radius.xl)
      Column()
        .width('100%')
        .height(180)
        .borderRadius(Theme.radius.xl)
        .linearGradient({
          angle: 180,
          colors: [
            ['rgba(10,14,26,0.12)', 0.0],
            ['rgba(10,14,26,0.88)', 1.0]
          ]
        })
      Column({ space: 6 }) {
        Text('把训练变成可完成的小游戏')
          .fontSize(Theme.type.caption)
          .fontColor('rgba(255,255,255,0.92)')
        Text('拾趣工坊')
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.heroOnPhoto())
        Text('计划、挑战、动作库和清单都在这里，全部由你创建。')
          .fontSize(Theme.type.footnote)
          .fontColor('rgba(255,255,255,0.95)')
      }
      .padding(Theme.space.s5)
      .alignItems(HorizontalAlign.Start)
      .width('100%')
    }
  }

  @Builder
  HubRow(title: string, sub: string, kind: string) {
    Row({ space: Theme.space.s3 }) {
      Column({ space: 4 }) {
        Text(title)
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
        Text(sub)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textSecondary)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textSecondary })
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .onClick((): void => { PracticeNav.openHub(kind) })
  }

  @Builder
  QuestCard(q: FunQuest) {
    Row({ space: Theme.space.s3 }) {
      Column() {
        AppIcon({ name: 'sparkle', iconSize: Theme.icon.lg, color: Theme.colors().brandPrimary })
      }
      .width(48)
      .height(48)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(Theme.colors().brandPrimaryContainer)
      .borderRadius(Theme.radius.md)

      Column({ space: 4 }) {
        Text(q.title)
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
        Text(`${q.theme} · ${this.progressOf(q).current}/${this.progressOf(q).target}${this.progressOf(q).unit}`)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().textSecondary)
        Text(q.status === 'done' ? '已完成' : '进行中')
          .fontSize(Theme.type.caption)
          .fontColor(q.status === 'done' ? Theme.colors().success : Theme.accentOnSurface())
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textSecondary })
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .onClick((): void => { TrainingDetailNav.openQuest(q.id) })
  }
}
