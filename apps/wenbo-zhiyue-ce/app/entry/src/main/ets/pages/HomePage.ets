import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { ExcerptItem, FolioOverview, ReadingDoc } from '../models/FolioModels'
import { FolioStore } from '../services/FolioStore'
import { FolioMedia } from '../services/FolioMedia'
import { DocImportService } from '../services/DocImportService'
import { DocListCard } from '../components/read/DocListCard'

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onReload') reloadToken: number = 0
  @StorageLink('folioEpoch') @Watch('onEpoch') folioEpoch: number = 0
  @State docs: ReadingDoc[] = []
  @State latest: ReadingDoc = new ReadingDoc()
  @State today: ExcerptItem = new ExcerptItem()
  @State overview: FolioOverview = new FolioOverview()
  @State toastText: string = ''
  onOpenReader: (id: string) => void = (_id: string) => {}
  onOpenPaste: (id: string) => void = (_id: string) => {}
  onOpenExcerpt: (id: string) => void = (_id: string) => {}
  onOpenDiagnose: () => void = () => {}

  aboutToAppear(): void {
    void this.load()
  }

  onReload(): void {
    void this.load()
  }

  onEpoch(): void {
    void this.load()
  }

  private async load(): Promise<void> {
    this.docs = await FolioStore.loadDocs()
    const latestFound = await FolioStore.latestDoc()
    this.latest = latestFound !== undefined ? latestFound : new ReadingDoc()
    const card = await FolioStore.todayCard()
    this.today = card !== undefined ? card : new ExcerptItem()
    this.overview = await FolioStore.overview()
  }

  private async importFile(): Promise<void> {
    const res = await DocImportService.pickLocal()
    if (!res.ok) {
      this.toastText = res.message.length > 0 ? res.message : '未导入'
      setTimeout((): void => { this.toastText = '' }, 2200)
      return
    }
    await FolioStore.saveDoc(res.doc)
    await this.load()
    if (res.message.length > 0) {
      this.toastText = res.message
      setTimeout((): void => { this.toastText = '' }, 2200)
    }
    this.onOpenReader(res.doc.id)
  }

  build() {
    Stack() {
      Scroll() {
        Column({ space: 14 }) {
          Stack() {
            Image(FolioMedia.cover('hero_desk'))
              .width('100%')
              .height(220)
              .objectFit(ImageFit.Cover)
            Column() {
              Text('智阅册')
                .fontSize(22)
                .fontWeight(FontWeight.Medium)
                .fontColor('#FFFFFF')
              Text('阅读 · 摘录 · 整理 · 回顾')
                .fontSize(13)
                .fontColor('#FFFFFF')
                .margin({ top: 6 })
            }
            .width('100%')
            .padding({ left: 20, right: 20, bottom: 18 })
            .linearGradient({
              angle: 180,
              colors: [['rgba(27,40,56,0.15)', 0], ['rgba(27,40,56,0.82)', 1]]
            })
          }
          .width('100%')
          .height(220)
          .borderRadius(Theme.radius.card)
          .clip(true)

          Row({ space: 10 }) {
            Column() {
              AppButton({ label: '导入文稿', onTap: (): void => { void this.importFile() } })
            }
            .layoutWeight(1)
            Column() {
              AppButton({
                label: '粘贴正文',
                variant: 'secondary',
                onTap: (): void => { this.onOpenPaste('') }
              })
            }
            .layoutWeight(1)
          }
          .width('100%')
          AppButton({
            label: '阅读节律自检',
            variant: 'secondary',
            onTap: (): void => { this.onOpenDiagnose() }
          })

          if (this.latest.id.length > 0) {
            Column({ space: 6 }) {
              Text('继续阅读')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().brandAccent)
                .width('100%')
              DocListCard({
                title: this.latest.title,
                formatLabel: this.latest.formatLabel(),
                progressLabel: this.latest.progressLabel(),
                updatedLabel: FolioStore.timeLabel(this.latest.lastReadAt),
                onTap: (): void => { this.onOpenReader(this.latest.id) }
              })
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)
          }

          Stack() {
            Image(FolioMedia.cover('banner_review'))
              .width('100%')
              .height(128)
              .objectFit(ImageFit.Cover)
            Column({ space: 6 }) {
              Text('今日智慧卡片')
                .fontSize(Theme.type.caption)
                .fontColor('#FFFFFF')
              Text(this.today.id.length > 0 ? this.today.text : '读过、记下，才会留下痕迹。导入文稿并写一条摘录后，这里每天会稳定出现一条。')
                .fontSize(Theme.type.body)
                .fontColor('#FFFFFF')
                .maxLines(3)
                .width('100%')
            }
            .width('100%')
            .padding(16)
            .linearGradient({
              angle: 180,
              colors: [['rgba(27,40,56,0.2)', 0], ['rgba(27,40,56,0.88)', 1]]
            })
          }
          .width('100%')
          .height(128)
          .borderRadius(Theme.radius.card)
          .clip(true)
          .onClick((): void => {
            if (this.today.id.length > 0) {
              this.onOpenExcerpt(this.today.id)
            }
          })

          Row({ space: 12 }) {
            Text(`文稿 ${this.overview.docCount}`)
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            Text(`摘录 ${this.overview.excerptCount}`)
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            Text(`阅读 ${this.overview.readMinutes} 分钟`)
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          }
          .width('100%')

          Text('我的文稿')
            .fontSize(Theme.type.subtitleS)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')

          if (this.docs.length === 0) {
            Column({ space: 10 }) {
              Image(FolioMedia.cover('empty_shelf'))
                .width('100%')
                .height(140)
                .objectFit(ImageFit.Cover)
                .borderRadius(12)
              AppEmpty({
                title: '书架还是空的',
                description: '导入或粘贴文稿开始阅读；也可先做阅读节律自检，生成可编辑的计划与摘录',
                actionLabel: '粘贴一篇',
                onAction: (): void => { this.onOpenPaste('') }
              })
            }
            .width('100%')
          } else {
            ForEach(this.docs, (d: ReadingDoc) => {
              DocListCard({
                title: d.title,
                formatLabel: d.formatLabel(),
                progressLabel: d.progressLabel(),
                updatedLabel: FolioStore.timeLabel(d.lastReadAt > 0 ? d.lastReadAt : d.createdAt),
                onTap: (): void => { this.onOpenReader(d.id) }
              })
            }, (d: ReadingDoc) => d.id)
          }
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          top: Theme.space.pageY,
          bottom: Theme.space.s10
        })
        .width('100%')
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .align(Alignment.Top)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.footnote)
          .fontColor('#FFFFFF')
          .padding({ left: 16, right: 16, top: 8, bottom: 8 })
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(Theme.radius.pill)
          .margin({ top: 16 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
