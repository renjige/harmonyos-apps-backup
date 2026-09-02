import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { ThoughtCardView } from '../components/box/ThoughtCardView'
import { CatalogItem, TagStat, ThoughtCard } from '../models/ThoughtModels'
import { ThoughtStore } from '../services/ThoughtStore'
import { ThoughtBoxBizService } from '../services/ThoughtBoxBizService'
import { DateHelper } from '../services/DateHelper'
import { ClassifyService } from '../services/ClassifyService'

@Component
export struct TagsPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('tbReload') @Watch('onReloadChange') tbReload: number = 0
  @Prop @Watch('onReloadChange') reloadToken: number = 0
  @Prop @Watch('onTabVisibleChange') tabVisible: boolean = false
  @State stats: TagStat[] = []
  @State presets: CatalogItem[] = []
  @State extra: string[] = []
  @State cloudTags: string[] = []
  @State newName: string = ''
  @State activeTag: string = ''
  @State tagged: ThoughtCard[] = []
  @State renameTo: string = ''
  @State tagEpoch: number = 0
  @State toastText: string = ''
  onOpenCard: (id: string) => void = (_id: string) => {}

  aboutToAppear(): void {
    void this.reload()
  }

  onReloadChange(): void {
    void this.reload()
  }

  onTabVisibleChange(): void {
    if (this.tabVisible) {
      void this.reload()
    }
  }

  private async reload(): Promise<void> {
    this.stats = await ThoughtStore.tagStats()
    this.presets = await ThoughtBoxBizService.loadTags()
    this.extra = await ThoughtStore.extraTags()
    this.cloudTags = TagsPage.buildCloud(this.stats, this.presets, this.extra)
    this.tagEpoch = this.tagEpoch + 1
    if (this.activeTag.length > 0) {
      this.tagged = await ThoughtStore.byTag(this.activeTag)
    }
  }

  private static buildCloud(stats: TagStat[], presets: CatalogItem[], extra: string[]): string[] {
    const names: string[] = []
    for (const s of stats) {
      ClassifyService.pushUnique(names, s.name)
    }
    for (const p of presets) {
      ClassifyService.pushUnique(names, p.title)
    }
    for (const e of extra) {
      ClassifyService.pushUnique(names, e)
    }
    return names
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2400)
  }

  private countOf(name: string): number {
    for (const s of this.stats) {
      if (s.name === name) {
        return s.count
      }
    }
    return 0
  }

  private async openTag(name: string): Promise<void> {
    this.activeTag = name
    this.renameTo = name
    this.tagged = await ThoughtStore.byTag(name)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  private closeTag(): void {
    this.activeTag = ''
    this.renameTo = ''
    AppStorage.setOrCreate('tabBarHidden', false)
    void this.reload()
  }

  private async addTag(): Promise<void> {
    const n = this.newName.trim()
    if (n.length === 0) {
      this.showToast('请输入标签名称')
      return
    }
    await ThoughtStore.addExtraTag(n)
    this.newName = ''
    await this.reload()
    this.showToast(`已新增标签「${n}」`)
  }

  private addTagTap(): void {
    void this.addTag()
  }

  private async saveRename(): Promise<void> {
    const from = this.activeTag
    const to = this.renameTo.trim()
    if (to.length === 0) {
      this.showToast('请输入新名称')
      return
    }
    if (from === to) {
      this.showToast('名称未变化')
      return
    }
    await ThoughtStore.renameTag(from, to)
    this.activeTag = to
    this.renameTo = to
    await this.reload()
    this.tagged = await ThoughtStore.byTag(to)
    this.showToast(`已重命名为「${to}」`)
  }

  private saveRenameTap(): void {
    void this.saveRename()
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column() {
        Scroll() {
          Column({ space: Theme.space.section }) {
            Stack({ alignContent: Alignment.BottomStart }) {
              Image($r('app.media.cover_tags'))
                .width('100%')
                .height(200)
                .objectFit(ImageFit.Cover)
              Column()
                .width('100%')
                .height(200)
                .linearGradient({
                  angle: 180,
                  colors: [
                    ['rgba(15,23,42,0.06)', 0.0],
                    ['rgba(15,23,42,0.42)', 0.45],
                    ['rgba(26,35,50,0.90)', 1.0]
                  ]
                })
              Column({ space: 6 }) {
                Text('标签柜')
                  .fontSize(Theme.type.titleL)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(Theme.colors().textOnInverse)
                Text(`${this.cloudTags.length} 个标签 · 点选打开抽屉`)
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().textOnInverse)
              }
              .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s6 })
            }
            .width('100%')
            .height(200)

            Column({ space: Theme.space.s3 }) {
              Flex({ wrap: FlexWrap.Wrap }) {
                ForEach(this.cloudTags, (name: string) => {
                  Row({ space: 6 }) {
                    Text(name)
                      .fontSize(Theme.type.footnote)
                      .fontColor(Theme.colors().labelOnContainer)
                    Text(`${this.countOf(name)}`)
                      .fontSize(Theme.type.caption)
                      .fontColor(Theme.colors().brandOnPrimary)
                      .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                      .backgroundColor(Theme.colors().brandPrimary)
                      .borderRadius(Theme.radius.pill)
                  }
                  .padding({ left: 12, right: 10, top: 8, bottom: 8 })
                  .margin({ right: 8, bottom: 8 })
                  .backgroundColor(Theme.colors().surfaceCard)
                  .borderRadius(Theme.radius.sm)
                  .border({ width: 1, color: Theme.colors().strokeStrong })
                  .onClick((): void => { void this.openTag(name) })
                }, (name: string) => `${this.tagEpoch}|${name}`)
              }
              .width('100%')

              Column({ space: Theme.space.s3 }) {
                TextInput({ text: this.newName, placeholder: '新建标签名称' })
                  .height(44)
                  .backgroundColor(Theme.colors().surfaceSubtle)
                  .borderRadius(Theme.radius.md)
                  .onChange((v: string) => { this.newName = v })
                Row() {
                  AppButton({
                    label: '新增标签',
                    variant: 'secondary',
                    onTap: (): void => { this.addTagTap() }
                  })
                }
                .width('100%')
                .onClick((): void => { this.addTagTap() })
              }
              .width('100%')
              .padding(Theme.space.s5)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.xl)
              .border({ width: 1, color: Theme.colors().strokeHairline })
            }
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
          }
          .padding({ bottom: 88 })
        }
        .layoutWeight(1)
        .onVisibleAreaChange([0.0, 1.0], (isVisible: boolean, currentRatio: number): void => {
          if (isVisible && currentRatio > 0 && this.tabVisible) {
            void this.reload()
          }
        })
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Theme.colors().surfacePage)

      if (this.activeTag.length > 0) {
        this.TagDetail()
      }

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().textOnInverse)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .margin({ top: Theme.space.s6 })
          .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  TagDetail() {
    Column() {
      Row() {
        Text('返回')
          .fontSize(Theme.type.footnote)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          .onClick((): void => { this.closeTag() })
        Blank()
        Text(this.activeTag)
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        Blank()
        Text('删除')
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().danger)
          .onClick((): void => {
            void ThoughtStore.removeTag(this.activeTag).then((): void => {
              this.showToast('已删除标签')
              this.closeTag()
            })
          })
      }
      .width('100%')
      TextInput({ text: this.renameTo, placeholder: '重命名标签' })
        .height(44)
        .onChange((v: string) => { this.renameTo = v })
      Row() {
        AppButton({
          label: '保存名称',
          onTap: (): void => { this.saveRenameTap() }
        })
      }
      .width('100%')
      .onClick((): void => { this.saveRenameTap() })
      Scroll() {
        Column({ space: Theme.space.s3 }) {
          if (this.tagged.length === 0) {
            AppEmpty({ title: '这个标签还是空的', description: '记下卡片时采用此标签即可出现在这里' })
          } else {
            ForEach(this.tagged, (c: ThoughtCard) => {
              ThoughtCardView({
                previewText: c.preview(),
                tagsLabel: c.tagLine(),
                shelfLabel: c.shelf,
                timeLabel: DateHelper.formatShort(c.createdAt),
                imagePath: c.imagePath,
                onOpen: (): void => { this.onOpenCard(c.id) }
              })
            }, (c: ThoughtCard) => `${this.tagEpoch}|${c.id}|${c.updatedAt}|${c.tagsCsv}`)
          }
        }
        .padding({ bottom: Theme.space.s8 })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .padding(Theme.space.pageX)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
