import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { LifeCraftCard } from '../components/life/LifeCraftCard'
import { LifeCraftItem, LifeCraftPreset } from '../models/LifeModels'
import { LifeDateHelper } from '../services/LifeLocalStore'
import { LifeCraftStore } from '../services/LifeCraftStore'
import { LifeDetailNav } from '../services/LifeDetailNav'

@Component
export struct CraftPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshChange') refreshToken: number = 0
  @State items: LifeCraftItem[] = []
  @State filterKind: string = 'all'
  @State board: string = ''
  @State toast: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.items = await LifeCraftStore.load()
  }

  private shown(): LifeCraftItem[] {
    return LifeCraftStore.filter(this.items, this.filterKind, this.board)
  }

  private showToast(msg: string): void {
    this.toast = msg
    setTimeout((): void => { this.toast = '' }, 1600)
  }

  private async addPreset(p: LifeCraftPreset): Promise<void> {
    const it = LifeCraftItem.create(LifeDateHelper.newId(), p.kind, p.title)
    it.category = p.category
    it.extra = p.extra
    it.body = p.body
    await LifeCraftStore.save(it)
    await this.reload()
    this.showToast('已加入锦囊，可点进去完善')
    LifeDetailNav.openCraft(it.id)
  }

  private openNew(): void {
    const k = this.filterKind === 'pin' || this.filterKind === 'all' ? 'tip' : this.filterKind
    LifeDetailNav.openCraftEditor('', k)
  }

  build() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Text('生活锦囊')
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.colors().textPrimary)
          Text('把经验、问题、目标、方案沉淀下来，变成可复用的生活方法')
            .fontSize(Theme.type.bodyS)
            .fontColor(Theme.colors().textSecondary)
            .lineHeight(20)

          Text('分类看板')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().brandDeep)
          Flex({ wrap: FlexWrap.Wrap }) {
            Text('全部领域')
              .fontSize(Theme.type.caption)
              .fontColor(this.board.length === 0 ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
              .padding({ left: 10, right: 10, top: 6, bottom: 6 })
              .margin({ right: Theme.space.s2, bottom: Theme.space.s1 })
              .backgroundColor(this.board.length === 0 ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.pill)
              .onClick((): void => { this.board = '' })
            ForEach(LifeCraftPreset.board(), (c: string) => {
              Text(c)
                .fontSize(Theme.type.caption)
                .fontColor(this.board === c ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
                .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                .margin({ right: Theme.space.s2, bottom: Theme.space.s1 })
                .backgroundColor(this.board === c ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                .borderRadius(Theme.radius.pill)
                .onClick((): void => { this.board = c })
            }, (c: string) => c)
          }
          .width('100%')

          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(LifeCraftPreset.kinds(), (k: string) => {
              Text(LifeCraftPreset.kindLabel(k))
                .fontSize(Theme.type.caption)
                .fontColor(this.filterKind === k ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
                .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                .margin({ right: Theme.space.s2, bottom: Theme.space.s1 })
                .backgroundColor(this.filterKind === k ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                .borderRadius(Theme.radius.pill)
                .onClick((): void => { this.filterKind = k })
            }, (k: string) => k)
          }
          .width('100%')

          Text('快捷开始（点一下生成，再自己改）')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textSecondary)
          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(LifeCraftPreset.starters(), (p: LifeCraftPreset) => {
              Text(`+ ${p.title}`)
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().brandPrimary)
                .padding({ left: 10, right: 10, top: 8, bottom: 8 })
                .margin({ right: Theme.space.s2, bottom: Theme.space.s2 })
                .backgroundColor(Theme.colors().brandPrimaryContainer)
                .borderRadius(Theme.radius.pill)
                .onClick((): void => { void this.addPreset(p) })
            }, (p: LifeCraftPreset) => `${p.kind}_${p.title}`)
          }
          .width('100%')

          if (this.shown().length === 0) {
            AppEmpty({
              title: '锦囊还是空的',
              description: '从经验卡、问题记录或生活目标开始',
              actionLabel: '新建一条',
              onAction: (): void => { this.openNew() }
            })
          } else {
            ForEach(this.shown(), (it: LifeCraftItem) => {
              LifeCraftCard({
                item: it,
                onTap: (): void => { LifeDetailNav.openCraft(it.id) }
              })
            }, (it: LifeCraftItem) => `${it.id}_${it.updatedAt}_${it.pinned ? '1' : '0'}_${it.progress}`)
          }
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          top: Theme.space.s4,
          bottom: Theme.space.s10
        })
        .width('100%')
      }
      .width('100%')
      .height('100%')
      .edgeEffect(EdgeEffect.Spring)

      Column() {
        AppIcon({ name: 'add', iconSize: Theme.icon.lg, color: Theme.colors().brandOnPrimary })
      }
      .width(56)
      .height(56)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(Theme.colors().brandPrimary)
      .borderRadius(Theme.radius.pill)
      .margin({ right: Theme.space.pageX, bottom: Theme.space.s8 })
      .onClick((): void => { this.openNew() })

      if (this.toast.length > 0) {
        Text(this.toast)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().brandOnPrimary)
          .padding({ left: 14, right: 14, top: 8, bottom: 8 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .position({ x: '16%', y: 16 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
