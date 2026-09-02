import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { ThemeSpace } from '../models/JianModels'
import { JianStore } from '../services/JianStore'
import { JianQuery } from '../services/JianQuery'
import { JianNav } from '../services/JianNav'
import { JianMedia } from '../services/JianMedia'
import { DateHelper } from '../services/DateHelper'

class ThemeCardVm {
  theme: ThemeSpace = new ThemeSpace()
  count: number = 0
}

@Component
export struct ThemePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageProp('jianDataRev') @Watch('onDataRevChange') jianDataRev: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @Prop bottomInset: number = 76
  @State cards: ThemeCardVm[] = []

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  onDataRevChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    const themes = await JianStore.loadThemes()
    const vms: ThemeCardVm[] = []
    for (const t of themes) {
      const vm = new ThemeCardVm()
      vm.theme = t
      vm.count = await JianQuery.themeCount(t.id)
      vms.push(vm)
    }
    this.cards = vms
  }

  build() {
    Column() {
      Row() {
        Text('主题空间')
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.colors().textPrimary)
          .layoutWeight(1)
        Column() {
          AppIcon({ name: 'add', iconSize: Theme.icon.md, color: Theme.colors().brandOnPrimary })
        }
        .width(40)
        .height(40)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(Theme.colors().brandPrimary)
        .borderRadius(Theme.radius.pill)
        .onClick((): void => { JianNav.openEditor('theme', '') })
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s4 })
      .width('100%')

      Text('把思考、阅读、灵感编进自己的专题房间')
        .fontSize(Theme.type.footnote)
        .fontColor(Theme.colors().textSecondary)
        .padding({ left: Theme.space.pageX, top: 4 })
        .width('100%')

      if (this.cards.length === 0) {
        // 空态必须可滚动：封面 + 文案高度常超过可视区，纯 Column 会被底栏裁切且无法下滑
        Scroll() {
          Column({ space: Theme.space.s3 }) {
            Image(JianMedia.coverTheme())
              .width('100%')
              .height(180)
              .objectFit(ImageFit.Cover)
              .borderRadius(Theme.radius.md)
            AppEmpty({
              title: '还没有主题',
              description: '可以先建「成长记录」或「产品思考」',
              actionLabel: '创建主题',
              onAction: (): void => { JianNav.openEditor('theme', '') }
            })
          }
          .width('100%')
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            top: Theme.space.s4,
            bottom: this.bottomInset + Theme.space.s6
          })
        }
        .layoutWeight(1)
        .width('100%')
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
        .align(Alignment.TopStart)
      } else {
        List() {
          ForEach(this.cards, (vm: ThemeCardVm) => {
            ListItem() {
              Stack({ alignContent: Alignment.BottomStart }) {
                Image(JianMedia.coverTheme())
                  .width('100%')
                  .height(140)
                  .objectFit(ImageFit.Cover)
                Column()
                  .width('100%')
                  .height(80)
                  .linearGradient({
                    angle: 180,
                    colors: [['rgba(18,38,47,0)', 0], ['rgba(18,38,47,0.8)', 1]]
                  })
                Column({ space: 4 }) {
                  Text(vm.theme.title)
                    .fontSize(Theme.type.subtitleM)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#F6F1E8')
                  Text(`${vm.count} 条 · ${DateHelper.displayDateFromTs(vm.theme.updatedAt)}`)
                    .fontSize(Theme.type.caption)
                    .fontColor('#F6F1E8')
                }
                .padding(Theme.space.s4)
              }
              .clip(true)
              .borderRadius(Theme.radius.md)
              .onClick((): void => { JianNav.openTheme(vm.theme.id) })
            }
            .padding({ bottom: Theme.space.s4 })
          }, (vm: ThemeCardVm) => vm.theme.id)
        }
        .layoutWeight(1)
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s4 })
        .contentStartOffset(0)
        .contentEndOffset(this.bottomInset + Theme.space.s6)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }
}
