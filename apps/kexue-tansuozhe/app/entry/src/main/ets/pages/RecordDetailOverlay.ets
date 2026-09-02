import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { DetailShell } from '../components/detail/DetailShell'
import { UserDiscovery } from '../models/ExplorationModels'
import { ExplorationStore } from '../services/ExplorationStore'
import { ExploreNav } from '../services/ExploreNav'
import { ExploreToast } from '../services/ExploreToast'

@Component
export struct RecordDetailOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('recordDetailId') detailId: string = ''
  @StorageLink('progressRev') @Watch('onRev') progressRev: number = 0
  @State item: UserDiscovery = new UserDiscovery()
  @State fav: boolean = false
  @State confirmDelete: boolean = false
  onToast: (msg: string) => void = () => {}

  aboutToAppear(): void {
    this.reload()
  }

  onRev(): void {
    this.reload()
  }

  private reload(): void {
    const d = ExplorationStore.findDiscovery(this.detailId)
    if (d !== undefined) {
      this.item = d
    }
    this.fav = ExplorationStore.snapshot().favoriteDiscoveryIds.indexOf(this.detailId) >= 0
  }

  private async toggleFav(): Promise<void> {
    this.fav = await ExplorationStore.toggleFavoriteDiscovery(this.detailId)
    const msg = this.fav ? '已收藏' : '已取消收藏'
    this.onToast(msg)
    ExploreToast.show(msg)
  }

  private async deleteRecord(): Promise<void> {
    await ExplorationStore.deleteDiscovery(this.detailId)
    this.onToast('记录已删除')
    ExploreToast.show('记录已删除')
    ExploreNav.closeRecordDetail()
  }

  build() {
    DetailShell({
      title: '探索详情',
      onClose: (): void => { ExploreNav.closeRecordDetail() }
    }) {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Stack({ alignContent: Alignment.BottomStart }) {
            Column()
              .width('100%')
              .height(140)
              .backgroundColor(Theme.colors().brandPrimary)
              .borderRadius(Theme.radius.lg)
            Column()
              .width('100%')
              .height(140)
              .linearGradient({
                angle: 180,
                colors: [['rgba(0,0,0,0)', 0.2], ['rgba(8,28,21,0.78)', 1.0]]
              })
              .borderRadius(Theme.radius.lg)
            Column({ space: 4 }) {
              if (this.item.isSample) {
                Text('示例')
                  .fontSize(Theme.type.caption)
                  .fontColor('#FFFFFF')
              }
              Text(this.item.title)
                .fontSize(Theme.type.title2)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FFFFFF')
              Text(`${ExplorationStore.categoryLabel(this.item.category)} · ${this.item.dateKey}`)
                .fontSize(Theme.type.caption)
                .fontColor('#FFFFFF')
            }
            .padding(Theme.space.s5)
            .alignItems(HorizontalAlign.Start)
            .width('100%')
          }
          .width('100%')

          this.Section('我注意到了什么', this.item.description)
          if (this.item.whyInteresting.length > 0) {
            this.Section('为什么有趣', this.item.whyInteresting)
          }
          if (this.item.feeling.length > 0) {
            this.Section('我的感受', this.item.feeling)
          }
          if (this.item.learned.length > 0) {
            this.Section('我理解了什么', this.item.learned)
          }
          if (this.item.placeText.length > 0) {
            this.Section('在哪里', this.item.placeText)
          }
          if (this.item.tags.length > 0) {
            Column({ space: Theme.space.s2 }) {
              Text('标签')
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colors().textPrimary)
                .width('100%')
              Flex({ wrap: FlexWrap.Wrap }) {
                ForEach(this.item.tags, (tag: string) => {
                  Text(tag)
                    .fontSize(Theme.type.footnote)
                    .fontColor(Theme.colors().brandPrimary)
                    .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                    .backgroundColor(Theme.colors().brandPrimaryContainer)
                    .borderRadius(Theme.radius.pill)
                    .margin({ right: 8, bottom: 8 })
                }, (tag: string) => tag)
              }
              .width('100%')
            }
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
            .border({ width: 1, color: Theme.colors().strokeHairline })
          }

          Row({ space: Theme.space.s3 }) {
            Column() {
              AppButton({
                label: '编辑',
                variant: 'primary',
                onTap: (): void => {
                  ExploreNav.closeRecordDetail()
                  ExploreNav.openRecordEditor(this.detailId)
                }
              })
            }
            .layoutWeight(1)
            Column() {
              AppButton({
                label: this.fav ? '已收藏' : '收藏',
                variant: 'secondary',
                onTap: (): void => { void this.toggleFav() }
              })
            }
            .layoutWeight(1)
          }
          .width('100%')

          if (this.confirmDelete) {
            Text('确定删除这条探索记录？此操作不可恢复。')
              .fontSize(Theme.type.footnote)
              .fontColor(Theme.colors().danger)
              .width('100%')
            Row({ space: Theme.space.s3 }) {
              Column() {
                AppButton({
                  label: '取消',
                  variant: 'secondary',
                  onTap: (): void => { this.confirmDelete = false }
                })
              }
              .layoutWeight(1)
              Column() {
                AppButton({
                  label: '确认删除',
                  variant: 'primary',
                  onTap: (): void => { void this.deleteRecord() }
                })
              }
              .layoutWeight(1)
            }
            .width('100%')
          } else {
            Column() {
              AppButton({
                label: '删除记录',
                variant: 'secondary',
                onTap: (): void => { this.confirmDelete = true }
              })
            }
            .width('100%')
          }
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          bottom: Theme.space.s10
        })
        .width('100%')
      }
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .width('100%')
      .height('100%')
    }
  }

  @Builder
  Section(title: string, body: string) {
    Column({ space: 6 }) {
      Text(title)
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')
      Text(body)
        .fontSize(Theme.type.body)
        .fontColor(Theme.colors().textSecondary)
        .lineHeight(22)
        .width('100%')
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .border({ width: 1, color: Theme.colors().strokeHairline })
  }
}
