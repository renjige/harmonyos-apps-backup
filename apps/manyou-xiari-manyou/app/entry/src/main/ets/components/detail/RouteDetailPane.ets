import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppLoading } from '../design-system/AppLoading'
import { DetailShell } from './DetailShell'
import { RouteItem, RouteNode } from '../../models/WanderModels'
import { WanderBizService } from '../../services/WanderBizService'
import { WanderDetailNav } from '../../services/WanderDetailNav'
import { WanderLocalStore } from '../../services/WanderLocalStore'
import { WanderMedia } from '../../services/WanderMedia'

@Component
export struct RouteDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRouteIdChange') routeId: string = ''
  @Prop @Watch('onRouteIdChange') refreshToken: number = 0
  @State item: RouteItem | undefined = undefined
  @State loading: boolean = true
  @State favored: boolean = false
  @State toastText: string = ''
  @State favScale: number = 1

  aboutToAppear(): void {
    void this.reload()
  }

  onRouteIdChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.item = await WanderBizService.findRoute(this.routeId)
    this.favored = await WanderLocalStore.isFavorite(this.routeId)
    this.loading = false
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout(() => {
      this.toastText = ''
    }, 2200)
  }

  private async toggleFav(): Promise<void> {
    this.favScale = 1.12
    setTimeout(() => {
      this.favScale = 1
    }, 180)
    this.favored = await WanderLocalStore.toggleFavorite(this.routeId)
    WanderLocalStore.notifyDataChanged()
    this.showToast(this.favored ? '已收藏这个漫游点' : '已取消收藏')
  }

  private kindLabel(): string {
    if (this.item === undefined) {
      return ''
    }
    const d = this.item.durationKind === 'weekend' ? '周末' : (this.item.durationKind === 'day' ? '一日' : '半日')
    const s = this.item.sceneKind === 'city' ? '城市' : '自然'
    return `${d} · ${s}`
  }

  private packText(): string {
    if (this.item === undefined) {
      return ''
    }
    let s = ''
    for (const p of this.item.packItems) {
      if (s.length > 0) {
        s += '  ·  '
      }
      s += p
    }
    return s
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      if (this.loading) {
        Column() {
          AppLoading({ label: '展开漫游点' })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
      } else if (this.item === undefined) {
        DetailShell({ title: '漫游点', onClose: () => WanderDetailNav.close() }) {
          AppEmpty({ title: '没有找到这个漫游点', description: '也许风把它吹走了', actionLabel: '返回', onAction: () => WanderDetailNav.close() })
        }
      } else {
        this.DetailBody()
      }
      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().brandOnPrimary)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .margin({ top: 56 })
          .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  DetailBody() {
    DetailShell({
      title: this.item !== undefined ? this.item.title : '漫游点',
      contentKey: this.favored ? 'fav1' : 'fav0',
      onClose: () => WanderDetailNav.close()
    }) {
      Column({ space: Theme.space.s5 }) {
        Stack({ alignContent: Alignment.BottomStart }) {
          Image(WanderMedia.resource(this.item !== undefined ? this.item.coverKey : 'hero_summer'))
            .width('100%')
            .height(240)
            .objectFit(ImageFit.Cover)
          Column()
            .width('100%')
            .height(120)
            .linearGradient({
              angle: 180,
              colors: [['rgba(36,53,43,0)', 0.05], ['rgba(36,53,43,0.78)', 1.0]]
            })
          Column({ space: 6 }) {
            Text(this.item !== undefined ? this.item.subtitle : '')
              .fontSize(Theme.type.caption)
              .fontColor('#F6F1E8')
            Text(this.item !== undefined ? this.item.title : '')
              .fontSize(Theme.type.title2)
              .fontWeight(FontWeight.Bold)
              .fontColor('#F6F1E8')
          }
          .padding(20)
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .height(240)
        .clip(true)

        Column({ space: 8 }) {
          Text(`${this.item !== undefined ? this.item.duration : ''}  ·  ${this.item !== undefined ? this.item.difficulty : ''}  ·  ${this.kindLabel()}`)
            .fontSize(Theme.type.footnote)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
            .width('100%')
          Text(this.item !== undefined ? this.item.summary : '')
            .fontSize(Theme.type.body)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        .alignItems(HorizontalAlign.Start)

        Column({ space: 8 }) {
          Text('这一段')
            .fontSize(Theme.type.subtitleM)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          Text(this.item !== undefined ? this.item.body : '')
            .fontSize(Theme.type.body)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .lineHeight(24)
            .width('100%')
        }
        .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
        .padding(18)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.md)
        .alignItems(HorizontalAlign.Start)

        Column({ space: 12 }) {
          Text('漫行节点')
            .fontSize(Theme.type.subtitleM)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
          ForEach(this.item !== undefined ? this.item.nodes : [], (n: RouteNode, idx: number) => {
            Row({ space: 12 }) {
              Column({ space: 4 }) {
                Column()
                  .width(10)
                  .height(10)
                  .borderRadius(Theme.radius.pill)
                  .backgroundColor(Theme.colors().brandAccent)
                Column()
                  .width(2)
                  .height(36)
                  .backgroundColor(Theme.colors().strokeStrong)
              }
              .width(16)
              Column({ space: 4 }) {
                Text(`${n.time}  ${n.title}`)
                  .fontSize(Theme.type.subtitleS)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .width('100%')
                Text(n.note)
                  .fontSize(Theme.type.footnote)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .width('100%')
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)
            }
            .width('100%')
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
          }, (n: RouteNode, idx: number) => `${idx}_${n.title}`)
        }

        Column({ space: 8 }) {
          Text('今日准备')
            .fontSize(Theme.type.subtitleM)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          Text(this.packText())
            .fontSize(Theme.type.subhead)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
          AppButton({
            label: '打开出行清单',
            variant: 'ghost',
            onTap: (): void => WanderDetailNav.openChecklist()
          })
        }
        .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
        .padding(18)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.md)
        .alignItems(HorizontalAlign.Start)

        Row({ space: 12 }) {
          AppButton({
            label: this.favored ? '已收藏' : '收藏漫游点',
            variant: this.favored ? 'secondary' : 'ghost',
            onTap: (): void => { void this.toggleFav() }
          }).layoutWeight(1).scale({ x: this.favScale, y: this.favScale })
          AppButton({
            label: '写入记录',
            variant: 'primary',
            onTap: (): void => {
              const t = this.item !== undefined ? this.item.title : ''
              const p = this.item !== undefined ? this.item.subtitle : ''
              WanderDetailNav.openJournalNew(t, p, this.item !== undefined ? this.item.coverKey : '')
            }
          }).layoutWeight(1)
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      }
      .width('100%')
    }
  }
}
