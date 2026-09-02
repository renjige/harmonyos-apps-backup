import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { SolidButton } from '../components/design-system/SolidButton'
import { FunQuest, FunQuestProgress, MoveItem } from '../models/TrainingModels'
import { FunQuestStore } from '../services/FunQuestStore'
import { FunQuestService } from '../services/FunQuestService'
import { PracticeHubStore } from '../services/PracticeHubStore'
import { MoveCatalog } from '../services/MoveCatalog'
import { TrainingDetailNav } from '../services/TrainingDetailNav'
import { PracticeNav } from '../services/PracticeNav'
import { VitalityService } from '../services/VitalityService'
import { DataRefresh } from '../services/DataRefresh'

@Component
export struct DiscoverPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('dataEpoch') @Watch('onDataEpoch') dataEpoch: number = 0
  @Prop @Watch('onTok') refreshToken: number = 0
  @State quests: FunQuest[] = []
  @State moves: MoveItem[] = []
  @State filter: string = '全部'
  @State toast: string = ''
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
    this.moves = PracticeHubStore.listMoves()
  }

  private visibleMoves(): MoveItem[] {
    const out: MoveItem[] = []
    for (const m of this.moves) {
      if (this.filter === '收藏') {
        if (m.favorited === '1') {
          out.push(m)
        }
      } else if (this.filter === '全部' || m.category === this.filter) {
        out.push(m)
      }
    }
    return out
  }

  private progressOf(q: FunQuest): FunQuestProgress {
    return FunQuestService.progress(q)
  }

  private showToast(msg: string): void {
    this.toast = msg
    setTimeout((): void => { this.toast = '' }, 2400)
  }

  private async cloneZone(zone: string): Promise<void> {
    const n = await MoveCatalog.importZone(zone)
    await VitalityService.award(n > 0 ? 4 : 0)
    DataRefresh.bump()
    this.reload()
    this.filter = zone
    this.showToast(n > 0 ? `已加入 ${n} 个${zone}动作` : '该专区动作已在图鉴中')
  }

  private async joinHall(key: string): Promise<void> {
    await FunQuestStore.saveItem(FunQuestService.fromHall(key))
    await VitalityService.award(5)
    DataRefresh.bump()
    this.reload()
    this.showToast('挑战已加入挑战馆')
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Scroll() {
        Column({ space: Theme.space.s5 }) {
          this.Hero()
          this.WorkshopBlock()
          Text('动作图鉴专区')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          Text('点专区即可复制可收藏的动作到本机，不是只读百科。')
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
          this.ZoneRow('热身专区', '热身')
          this.ZoneRow('拉伸专区', '拉伸')
          this.ZoneRow('力量专区', '力量')
          this.ZoneRow('平衡专区', '平衡')
          this.ZoneRow('放松专区', '放松')

          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(['全部', '热身', '拉伸', '力量', '平衡', '放松', '收藏'], (cat: string) => {
              Text(cat)
                .fontSize(Theme.type.bodyS)
                .fontColor(this.filter === cat ? '#FFFFFF' : Theme.colors().textSecondary)
                .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                .backgroundColor(this.filter === cat ? Theme.primaryButtonFill() : Theme.colors().surfaceSubtle)
                .borderRadius(Theme.radius.pill)
                .margin({ right: 8, bottom: 8 })
                .onClick((): void => { this.filter = cat })
            }, (cat: string) => cat)
          }
          .width('100%')

          if (this.visibleMoves().length === 0) {
            AppEmpty({
              title: '图鉴还是空的',
              description: '先点上方专区加入动作，再打开详情收藏或改成自己的组合'
            })
          } else {
            ForEach(this.visibleMoves(), (m: MoveItem) => {
              Row() {
                Column({ space: 4 }) {
                  Text(m.title)
                    .fontSize(Theme.type.subhead)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(Theme.colors().textPrimary)
                  Text(`${m.category}${m.favorited === '1' ? ' · 已收藏' : ''}`)
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
              .onClick((): void => { PracticeNav.openHub('move') })
            }, (m: MoveItem) => m.id)
          }

          Text('运动挑战馆')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          this.HallCard('7 天运动挑战', '跟练或记一次即可计入', 'd7')
          this.HallCard('21 天习惯挑战', '把连续运动变成故事', 'd21')
          this.HallCard('月度坚持挑战', '让日历亮起来', 'd30')

          Column() {
            SolidButton({
              label: '自定义挑战',
              tone: 'secondary',
              onTap: (): void => { this.onCreateQuest() }
            })
          }
          .width('100%')
          .onClick((): void => { this.onCreateQuest() })

          Column() {
            SolidButton({
              label: '本周训练复盘',
              tone: 'secondary',
              onTap: (): void => { this.onOpenRecap() }
            })
          }
          .width('100%')
          .onClick((): void => { this.onOpenRecap() })

          Text('我的挑战')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          if (this.quests.length === 0) {
            AppEmpty({
              title: '挑战馆还是空的',
              description: '加入 7 天挑战，跟练或记一次运动即可计入'
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
      .backgroundColor(Theme.pageBg(this.themeEpoch))
      .edgeEffect(EdgeEffect.Spring)

      if (this.toast.length > 0) {
        Text(this.toast)
          .fontSize(Theme.type.bodyS)
          .fontColor('#FFFFFF')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor('rgba(15,23,42,0.88)')
          .borderRadius(Theme.radius.pill)
          .margin({ top: 48 })
          .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  WorkshopBlock() {
    Column({ space: Theme.space.s3 }) {
      Text('运动生活工具')
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')
      Text('清单、笔记与目标帮你组织运动日常，与跟练/呼吸/图鉴配合使用。')
        .fontSize(Theme.type.footnote)
        .fontColor(Theme.colors().textSecondary)
        .width('100%')
      this.WorkshopRow('运动任务清单', '训练前热身 + 训练后拉伸勾选', 'check')
      this.WorkshopRow('运动笔记', '写心得、感悟、小技巧', 'card')
      this.WorkshopRow('阶段目标', '设定次数/分钟目标，随运动更新', 'goal')
    }
    .width('100%')
  }

  @Builder
  WorkshopRow(title: string, subtitle: string, hub: string) {
    Row() {
      Column({ space: 4 }) {
        Text(title)
          .fontSize(Theme.type.body)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')
        Text(subtitle)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textTertiary })
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(Theme.cardBg(this.themeEpoch))
    .borderRadius(Theme.radius.lg)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .onClick((): void => { PracticeNav.openHub(hub) })
  }

  @Builder
  Hero() {
    Stack({ alignContent: Alignment.BottomStart }) {
      Image($r('app.media.fun_quest_bg'))
        .width('100%')
        .height(168)
        .objectFit(ImageFit.Cover)
        .borderRadius(Theme.radius.xl)
      Column()
        .width('100%')
        .height(168)
        .borderRadius(Theme.radius.xl)
        .linearGradient({
          angle: 180,
          colors: [
            ['rgba(10,14,26,0.12)', 0.0],
            ['rgba(10,14,26,0.88)', 1.0]
          ]
        })
      Column({ space: 6 }) {
        Text('发现')
          .fontSize(Theme.type.caption)
          .fontColor('rgba(255,255,255,0.92)')
        Text('动作图鉴 · 挑战馆 · 运动工具')
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.heroOnPhoto())
        Text('五专区动作可收藏；挑战按运动天数推进。')
          .fontSize(Theme.type.footnote)
          .fontColor('rgba(255,255,255,0.95)')
      }
      .padding(Theme.space.s5)
      .alignItems(HorizontalAlign.Start)
      .width('100%')
    }
  }

  @Builder
  ZoneRow(title: string, zone: string) {
    Row() {
      Text(title)
        .fontSize(Theme.type.body)
        .fontColor(Theme.colors().textPrimary)
        .layoutWeight(1)
      Text('加入图鉴')
        .fontSize(Theme.type.caption)
        .fontColor('#FFFFFF')
        .padding({ left: 10, right: 10, top: 6, bottom: 6 })
        .backgroundColor(Theme.primaryButtonFill())
        .borderRadius(Theme.radius.pill)
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .onClick((): void => { void this.cloneZone(zone) })
  }

  @Builder
  HallCard(title: string, sub: string, key: string) {
    Row() {
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
      Text('加入')
        .fontSize(Theme.type.caption)
        .fontColor('#FFFFFF')
        .padding({ left: 12, right: 12, top: 6, bottom: 6 })
        .backgroundColor(Theme.primaryButtonFill())
        .borderRadius(Theme.radius.pill)
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .onClick((): void => { void this.joinHall(key) })
  }

  @Builder
  QuestCard(q: FunQuest) {
    Row({ space: Theme.space.s3 }) {
      Column({ space: 4 }) {
        Text(q.title)
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
        Text(`${this.progressOf(q).current}/${this.progressOf(q).target}${this.progressOf(q).unit}`)
          .fontSize(Theme.type.footnote)
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
    .onClick((): void => { TrainingDetailNav.openQuest(q.id) })
  }
}
