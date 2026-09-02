import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { CollectItem, CollectKindMeta } from '../../models/CollectModels'
import { CollectStore } from '../../services/CollectStore'

@Component
export struct CollectDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: CollectItem = new CollectItem()
  onClose: () => void = () => {}
  onDeleted: () => void = () => {}
  onEdit: () => void = () => {}
  @State confirmDelete: boolean = false

  private kindLabel(): string {
    return CollectKindMeta.of(this.item.kind).label
  }

  private accent(): string {
    return CollectKindMeta.of(this.item.kind).accent
  }

  private async doDelete(): Promise<void> {
    await CollectStore.remove(this.item.id)
    this.confirmDelete = false
    this.onDeleted()
  }

  build() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(Theme.colors().overlayScrim)
        .onClick((): void => { this.onClose() })

      Column({ space: 0 }) {
        Row() {
          Row() {
            AppIcon({ name: 'close', iconSize: Theme.icon.lg, color: Theme.colors().textPrimary })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .onClick((): void => { this.onClose() })
          Blank()
          Text(this.kindLabel())
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          Blank()
          Column().width(44)
        }
        .width('100%')
        .padding({ left: Theme.space.s2, right: Theme.space.s2, top: Theme.space.s2 })

        Stack({ alignContent: Alignment.BottomStart }) {
          Column()
            .width('100%')
            .height(140)
            .backgroundColor(this.accent())
            .borderRadius({ topLeft: Theme.radius.xl, topRight: Theme.radius.xl })
          Column() {
            Blank()
            Column({ space: 6 }) {
              Text(this.item.title)
                .fontSize(Theme.type.title3)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FFFFFF')
                .maxLines(2)
              if (this.item.sub.length > 0) {
                Text(this.item.sub)
                  .fontSize(Theme.type.bodyS)
                  .fontColor('#FFFFFF')
                  .maxLines(2)
              }
            }
            .width('100%')
            .padding(Theme.space.s4)
            .linearGradient({
              angle: 180,
              colors: [['rgba(0,0,0,0)', 0], ['rgba(0,0,0,0.55)', 1]]
            })
          }
          .width('100%')
          .height('100%')
        }
        .width('100%')
        .height(140)

        Scroll() {
          Column({ space: Theme.space.s4 }) {
            if (this.item.extra.length > 0) {
              Column({ space: 4 }) {
                Text('备注')
                  .fontSize(Theme.type.caption)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                Text(this.item.extra)
                  .fontSize(Theme.type.body)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              }
              .width('100%')
              .alignItems(HorizontalAlign.Start)
            }
            if (this.item.tags.length > 0) {
              Flex({ wrap: FlexWrap.Wrap }) {
                ForEach(this.item.tags.split(','), (tag: string) => {
                  if (tag.length > 0) {
                    Text(tag)
                      .fontSize(Theme.type.caption)
                      .fontColor(Theme.colors().brandPrimary)
                      .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                      .backgroundColor(Theme.colors().brandPrimaryContainer)
                      .borderRadius(Theme.radius.pill)
                      .margin({ right: 6, bottom: 6 })
                  }
                }, (tag: string) => tag)
              }
              .width('100%')
            }
            Column({ space: 4 }) {
              Text('正文')
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              Text(this.item.body.length > 0 ? this.item.body : '暂无正文，可编辑补充观赛感受或收藏理由。')
                .fontSize(Theme.type.body)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)

            AppButton({ label: '编辑', variant: 'primary', onTap: (): void => { this.onEdit() } })
            AppButton({
              label: '删除',
              variant: 'secondary',
              onTap: (): void => { this.confirmDelete = true }
            })
          }
          .width('100%')
          .padding(Theme.space.pageX)
          .padding({ bottom: Theme.space.s10 })
        }
        .layoutWeight(1)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
      }
      .width('100%')
      .height('88%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
      .borderRadius({ topLeft: Theme.radius.xl, topRight: Theme.radius.xl })
      .position({ x: 0, y: '12%' })

      if (this.confirmDelete) {
        Column({ space: Theme.space.s4 }) {
          Text('确认删除这条记录？')
            .fontSize(Theme.type.body)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          AppButton({ label: '确认删除', variant: 'danger', onTap: (): void => { void this.doDelete() } })
          AppButton({ label: '取消', variant: 'secondary', onTap: (): void => { this.confirmDelete = false } })
        }
        .width('80%')
        .padding(Theme.space.s5)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.xl)
      }
    }
    .width('100%')
    .height('100%')
    .zIndex(50)
    .onAppear((): void => { AppStorage.setOrCreate('tabBarHidden', true) })
    .onDisAppear((): void => { AppStorage.setOrCreate('tabBarHidden', false) })
  }
}
