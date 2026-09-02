import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { RmCheckItem, RmChecklist, RmCategory, RmLabels, RmLookbackItem } from '../models/RmModels'
import { RmStore } from '../services/RmStore'
import { RmDetailNav } from '../services/RmDetailNav'
import { ChecklistListCard } from '../components/rm/ChecklistListCard'
import { StatTileCard } from '../components/rm/StatTileCard'

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageProp('RmDataRev') @Watch('onDataRev') dataRev: number = 0
  @Prop @Watch('onRefresh') refreshToken: number = 0
  @Prop bottomInset: number = 76
  @State checklistCount: number = 0
  @State doneCount: number = 0
  @State treasureCount: number = 0
  @State themeCount: number = 0
  @State inboxCount: number = 0
  @State recentDone: RmCheckItem[] = []
  @State recentLists: RmChecklist[] = []
  @State cats: RmCategory[] = []
  @State look: RmLookbackItem = new RmLookbackItem()
  @State prompt: string = RmLabels.promptOfDay()
  @State statsEpoch: number = 0

  aboutToAppear(): void {
    void this.reload()
  }

  onRefresh(): void {
    void this.reload()
  }

  onDataRev(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    const stats = await RmStore.computeStats()
    this.checklistCount = stats.entryCount
    this.doneCount = stats.doneItemCount
    this.treasureCount = stats.treasureCount
    this.themeCount = stats.themeCount
    this.inboxCount = stats.inboxCount
    this.statsEpoch = this.statsEpoch + 1
    this.recentDone = await RmStore.recentDoneItems(4)
    this.recentLists = await RmStore.recentChecklists(4)
    this.cats = await RmStore.loadCategories()
    this.look = await RmStore.buildLookback()
    this.prompt = RmLabels.promptOfDay()
  }

  private openLook(): void {
    if (this.look.sourceKind === 'item' && this.look.sourceId.length > 0) {
      RmDetailNav.openItem(this.look.sourceId)
      return
    }
    if (this.look.sourceKind === 'wish' && this.look.sourceId.length > 0) {
      RmDetailNav.openWish(this.look.sourceId)
      return
    }
    if (this.look.sourceId.length > 0) {
      RmDetailNav.openChecklist(this.look.sourceId)
    }
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s5 }) {
        Stack({ alignContent: Alignment.BottomStart }) {
          Image($r('app.media.hero_sky_path'))
            .width('100%')
            .height(220)
            .objectFit(ImageFit.Cover)
          Column()
            .width('100%')
            .height(140)
            .linearGradient({ angle: 180, colors: [['rgba(12,74,110,0)', 0], ['rgba(12,74,110,0.88)', 1]] })
          Column({ space: 6 }) {
            Text('漫游空间')
              .fontSize(Theme.type.title2)
              .fontWeight(FontWeight.Bold)
              .fontColor('#F8FAFC')
            Text(this.prompt)
              .fontSize(Theme.type.subtitleS)
              .fontColor('#F8FAFC')
          }
          .padding({ left: Theme.space.s5, right: Theme.space.s5, bottom: Theme.space.s5 })
        }
        .width('100%')
        .clip(true)
        .borderRadius(Theme.radius.lg)

        Row({ space: Theme.space.s3 }) {
          Column({ space: 6 }) {
            Text('新建清单')
              .fontSize(Theme.type.subtitleS)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().brandOnPrimary)
            Text('规划一项新体验')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().brandOnPrimary)
          }
          .layoutWeight(1.2)
          .padding(Theme.space.s4)
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(Theme.radius.md)
          .onClick((): void => { RmDetailNav.openChecklistEditor('', 'today') })

          Column({ space: 6 }) {
            Text('添加愿望')
              .fontSize(Theme.type.subtitleS)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().brandDeep)
            Text('保存未来想做的事')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
          }
          .layoutWeight(1)
          .padding(Theme.space.s4)
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.md)
          .onClick((): void => { RmDetailNav.openWishEditor('') })
        }
        .width('100%')

        Row({ space: Theme.space.s2 }) {
          StatTileCard({ label: '清单', value: this.checklistCount })
          StatTileCard({ label: '完成', value: this.doneCount })
          StatTileCard({ label: '收藏', value: this.treasureCount })
          StatTileCard({ label: '主题', value: this.themeCount })
        }
        .width('100%')
        .key(`stats_${this.statsEpoch}_${this.dataRev}`)

        if (this.inboxCount > 0) {
          Row() {
            AppIcon({ name: 'alert', iconSize: Theme.icon.sm, color: Theme.colors().warning })
            Text(`有 ${this.inboxCount} 份清单进行中`)
              .fontSize(Theme.type.footnote)
              .fontColor(Theme.colors().textPrimary)
              .margin({ left: 8 })
              .layoutWeight(1)
            Text('去查看')
              .fontSize(Theme.type.footnote)
              .fontColor(Theme.colors().brandPrimary)
          }
          .width('100%')
          .padding(Theme.space.s3)
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.md)
          .onClick((): void => {
            AppStorage.setOrCreate('rmJumpChecklistInbox', true)
            AppStorage.setOrCreate('RmActiveTab', 1)
          })
        }

        Text(this.recentDone.length > 0 ? '最近完成' : (this.recentLists.length > 0 ? '我的清单' : '最近完成'))
          .fontSize(Theme.type.subtitleS)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')
        if (this.recentDone.length === 0 && this.recentLists.length === 0) {
          AppEmpty({
            title: '漫游档案还是空的',
            description: '新建清单后，在清单里添加一项并点「完成」',
            actionLabel: '新建清单',
            onAction: (): void => { RmDetailNav.openChecklistEditor('', 'today') }
          })
        } else if (this.recentDone.length > 0) {
          ForEach(this.recentDone, (it: RmCheckItem) => {
            Row({ space: Theme.space.s3 }) {
              Image($r('app.media.theme_read'))
                .width(56)
                .height(56)
                .borderRadius(Theme.radius.sm)
                .objectFit(ImageFit.Cover)
              Column({ space: 4 }) {
                Text(it.title)
                  .fontSize(Theme.type.subtitleS)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Theme.colors().textPrimary)
                  .maxLines(1)
                Text(it.harvest.length > 0 ? it.harvest : '已完成一项体验')
                  .fontSize(Theme.type.footnote)
                  .fontColor(Theme.colors().textSecondary)
                  .maxLines(2)
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)
            }
            .width('100%')
            .padding(Theme.space.s3)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
            .onClick((): void => { RmDetailNav.openItem(it.id) })
          }, (it: RmCheckItem) => it.id)
        } else {
          ForEach(this.recentLists, (cl: RmChecklist) => {
            ChecklistListCard({
              entry: cl,
              categoryLabel: RmStore.categoryLabel(cl.categoryKey, this.cats),
              onOpen: (): void => { RmDetailNav.openChecklist(cl.id) }
            })
          }, (cl: RmChecklist) => cl.id)
        }

        Column({ space: 6 }) {
          Image($r('app.media.hero_sky_path'))
            .width('100%')
            .height(72)
            .objectFit(ImageFit.Cover)
            .borderRadius(Theme.radius.sm)
          Text('智慧回望')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().warning)
            .width('100%')
          Text(this.look.title)
            .fontSize(Theme.type.subtitleS)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          Text(this.look.body)
            .fontSize(Theme.type.body)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
        }
        .width('100%')
        .padding(Theme.space.s4)
        .backgroundColor(Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.md)
        .onClick((): void => { this.openLook() })

        Row() {
          AppButton({ label: '新建主题空间', variant: 'secondary', onTap: (): void => { RmDetailNav.openThemeEditor('') } })
        }
        .width('100%')

        Column().height(this.bottomInset + Theme.space.s4)
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s3 })
    }
    .width('100%')
    .height('100%')
    .align(Alignment.Top)
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
    .onAppear((): void => { void this.reload() })
    .backgroundColor(Theme.colors().surfacePage)
  }
}
