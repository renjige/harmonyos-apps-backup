import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { ThemeSpace, Narrative, SparkItem } from '../../models/XingyuModels'
import { XingyuMedia } from '../../services/XingyuMedia'
import { XingyuStore } from '../../services/XingyuStore'
import { XingyuNav } from '../../services/XingyuNav'
import { DateHelper } from '../../services/DateHelper'
import { NarrativeCard } from '../xingyu/ArchiveCards'

@Component
export struct ThemeDetailPane {
  @StorageLink('xingyuRev') @Watch('onRev') xingyuRev: number = 0
  @Prop themeId: string = ''
  @State theme: ThemeSpace = new ThemeSpace()
  @State narratives: Narrative[] = []
  @State sparks: SparkItem[] = []
  @State confirmDelete: boolean = false
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onRev(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    const t = await XingyuStore.findTheme(this.themeId)
    if (t !== undefined) {
      this.theme = t
    }
    this.narratives = await XingyuStore.narrativesOfTheme(this.themeId)
    this.sparks = await XingyuStore.sparksOfTheme(this.themeId)
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout(() => {
      this.toastText = ''
    }, 2200)
  }

  private addNarrative(): void {
    XingyuNav.setPendingTheme(this.themeId)
    XingyuNav.openEditor('narrative', '')
  }

  private async doDelete(): Promise<void> {
    if (!this.confirmDelete) {
      this.confirmDelete = true
      this.showToast('再点一次确认删除主题')
      return
    }
    await XingyuStore.deleteTheme(this.themeId)
    XingyuNav.closeTheme()
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Stack({ alignContent: Alignment.BottomStart }) {
            Image(XingyuMedia.image(this.theme.coverKey))
              .width('100%')
              .height(200)
              .objectFit(ImageFit.Cover)
            Column()
              .width('100%')
              .height(110)
              .linearGradient({
                angle: 180,
                colors: [['rgba(18,24,43,0.05)', 0], ['rgba(18,24,43,0.82)', 1]]
              })
            Column({ space: 6 }) {
              Text('主题空间')
                .fontSize(Theme.type.caption)
                .fontColor('#C4A574')
              Text(this.theme.title)
                .fontSize(Theme.type.title2)
                .fontWeight(FontWeight.Bold)
                .fontColor('#F6F3EC')
              Text(`${this.narratives.length + this.sparks.length} 条内容 · ${DateHelper.displayDate(DateHelper.keyFromDate(new Date(this.theme.createdAt)))} 创建`)
                .fontSize(Theme.type.footnote)
                .fontColor('#D4CFC4')
            }
            .padding(Theme.space.s4)
            .width('100%')
          }
          .clip(true)
          .borderRadius(Theme.radius.lg)

          AppButton({
            label: '在此主题写下叙事',
            onTap: () => this.addNarrative()
          })
          AppButton({
            label: '编辑主题',
            variant: 'secondary',
            onTap: () => XingyuNav.openEditor('theme', this.themeId)
          })

          Text('收录的叙事')
            .fontSize(Theme.type.subtitleS)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')

          if (this.narratives.length === 0 && this.sparks.length === 0) {
            AppEmpty({
              title: '主题还是空的',
              description: '把叙事或灵感归入这里，形成你的星域。',
              actionLabel: '写下第一条',
              onAction: () => this.addNarrative()
            })
          }

          ForEach(this.narratives, (n: Narrative) => {
            NarrativeCard({
              title: n.title,
              dateKey: n.dateKey,
              statusLabel: n.statusLabel(),
              preview: n.preview(),
              coverKey: n.coverKey(),
              onOpen: () => XingyuNav.openNarrative(n.id)
            })
          }, (n: Narrative) => n.id)

          ForEach(this.sparks, (s: SparkItem) => {
            NarrativeCard({
              title: s.title,
              dateKey: s.dateKey,
              statusLabel: s.kindLabel(),
              preview: s.preview(),
              coverKey: 'cover_hobby',
              onOpen: () => XingyuNav.openSpark(s.id)
            })
          }, (s: SparkItem) => s.id)

          AppButton({
            label: this.confirmDelete ? '确认删除主题' : '删除主题',
            variant: 'danger',
            onTap: () => {
              void this.doDelete()
            }
          })
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
        .width('100%')
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)
      .align(Alignment.Top)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().brandOnPrimary)
          .padding(Theme.space.s3)
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(Theme.radius.sm)
          .margin({ top: Theme.space.s4 })
      }
    }
    .width('100%')
    .height('100%')
  }
}
