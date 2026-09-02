import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { ThoughtCardView } from '../components/box/ThoughtCardView'
import { CatalogItem, TagStat, ThoughtCard } from '../models/ThoughtModels'
import { ThoughtStore } from '../services/ThoughtStore'
import { ThoughtBoxBizService } from '../services/ThoughtBoxBizService'
import { BoxMedia } from '../services/BoxMedia'
import { DateHelper } from '../services/DateHelper'

@Component
export struct TagsPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('tbReload') @Watch('onReloadChange') tbReload: number = 0
  @Prop @Watch('onReloadChange') reloadToken: number = 0
  @State stats: TagStat[] = []
  @State presets: CatalogItem[] = []
  @State extra: string[] = []
  @State newName: string = ''
  @State activeTag: string = ''
  @State tagged: ThoughtCard[] = []
  @State renameTo: string = ''
  @State toastText: string = ''
  onOpenCard: (id: string) => void = (_id: string) => {}

  aboutToAppear(): void {
    void this.reload()
  }

  onReloadChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.stats = await ThoughtStore.tagStats()
    this.presets = await ThoughtBoxBizService.loadTags()
    this.extra = await ThoughtStore.extraTags()
    if (this.activeTag.length > 0) {
      this.tagged = await ThoughtStore.byTag(this.activeTag)
    }
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2400)
  }

  private cloudNames(): string[] {
    const names: string[] = []
    for (const s of this.stats) {
      names.push(s.name)
    }
    for (const p of this.presets) {
      let found = false
      for (const n of names) {
        if (n === p.title) {
          found = true
        }
      }
      if (!found) {
        names.push(p.title)
      }
    }
    for (const e of this.extra) {
      let found = false
      for (const n of names) {
        if (n === e) {
          found = true
        }
      }
      if (!found) {
        names.push(e)
      }
    }
    return names
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
    AppStorage.setOrCreate('tabBarHidden', false)
  }

  build() {
    Stack() {
      Column() {
        Text('标签云')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s4 })

        Image(BoxMedia.resource('cover_tags'))
          .width('100%')
          .height(120)
          .objectFit(ImageFit.Cover)
          .borderRadius(Theme.radius.lg)
          .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
          .clip(true)

        Scroll() {
          Column({ space: Theme.space.s3 }) {
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.cloudNames(), (name: string) => {
                Text(`${name} ${this.countOf(name)}`)
                  .fontSize(Theme.type.footnote)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                  .margin({ right: 8, bottom: 8 })
                  .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
                  .borderRadius(Theme.radius.pill)
                  .border({ width: 1, color: Theme.colors().strokeStrong })
                  .onClick((): void => { void this.openTag(name) })
              }, (name: string) => name)
            }
            .width('100%')

            TextInput({ text: this.newName, placeholder: '新建标签名称' })
              .height(44)
              .onChange((v: string) => { this.newName = v })
            AppButton({
              label: '新增标签',
              variant: 'secondary',
              onTap: (): void => {
                void ThoughtStore.addExtraTag(this.newName).then((): void => {
                  this.newName = ''
                  this.showToast('已新增标签')
                  void this.reload()
                })
              }
            })
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s8, top: Theme.space.s3 })
        }
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.activeTag.length > 0) {
        this.TagDetail()
      }

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().textOnInverse)
          .padding(12)
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.md)
          .margin({ top: 56 })
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
              void this.reload()
            })
          })
      }
      .width('100%')
      TextInput({ text: this.renameTo, placeholder: '重命名标签' })
        .height(44)
        .onChange((v: string) => { this.renameTo = v })
      AppButton({
        label: '保存名称',
        onTap: (): void => {
          void ThoughtStore.renameTag(this.activeTag, this.renameTo).then((): void => {
            this.activeTag = this.renameTo.trim()
            this.showToast('已重命名')
            void this.reload()
          })
        }
      })
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
                  onOpen: (): void => { this.onOpenCard(c.id) }
                })
            }, (c: ThoughtCard) => `${c.id}|${c.updatedAt}|${c.tagsCsv}`)
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
