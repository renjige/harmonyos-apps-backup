import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppCard } from '../design-system/AppCard'
import { KnowledgeFact, KnowledgeObject, TimelinePoint } from '../../models/KnowledgeModels'
import { GewuMedia } from '../../services/GewuMedia'
import { GewuStore } from '../../services/GewuStore'
import { KnowledgeCatalog } from '../../services/KnowledgeCatalog'
import { GewuDetailNav } from '../../services/GewuDetailNav'
import { InquiryNotePane } from '../gewu/InquiryNotePane'
import { FieldStore } from '../../services/FieldStore'
import { AlbumKind } from '../../models/FieldModels'

@Component
export struct KnowledgeDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: KnowledgeObject = new KnowledgeObject()
  @Prop @Watch('onItemChange') refreshToken: number = 0
  @StorageLink('detailRefreshToken') @Watch('onItemChange') detailTick: number = 0
  onDataChanged: () => void = () => {}
  @State isFavorite: boolean = false
  @State isDeepen: boolean = false
  @State albumKey: string = ''
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.syncFlags()
  }

  onItemChange(): void {
    void this.syncFlags()
  }

  private async syncFlags(): Promise<void> {
    this.isFavorite = await GewuStore.isFavorite(this.item.id)
    this.isDeepen = await GewuStore.isDeepen(this.item.id)
    this.albumKey = await FieldStore.albumOf(this.item.id)
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2400)
  }

  private async handleFavorite(): Promise<void> {
    const added = await GewuStore.toggleFavorite(this.item.id)
    this.isFavorite = added
    this.showToast(added ? '已加入收藏' : '已取消收藏')
    this.onDataChanged()
  }

  private async handleDeepen(): Promise<void> {
    const added = await GewuStore.toggleDeepen(this.item.id)
    this.isDeepen = added
    this.showToast(added ? '已标记想深究' : '已取消深究标记')
    this.onDataChanged()
  }

  private async handleAlbum(album: string): Promise<void> {
    const next = this.albumKey === album ? '' : album
    await FieldStore.setAlbum(this.item.id, next)
    this.albumKey = next
    this.showToast(next.length > 0 ? `已放入${next}` : '已移出收藏夹')
    this.onDataChanged()
  }

  private startObservation(): void {
    GewuDetailNav.seedAndEdit(this.item.title, this.item.atlasKind, this.item.coverKey, this.item.id)
  }

  private startCompare(other: KnowledgeObject): void {
    AppStorage.setOrCreate('recordSeedBody',
      `对照：${this.item.title} 与 ${other.title}\n相同点：\n不同点：\n今日体会：`)
    GewuDetailNav.seedAndEdit(
      `${this.item.title} × ${other.title}`,
      this.item.atlasKind,
      this.item.coverKey,
      this.item.id
    )
  }

  build() {
    Stack() {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Stack({ alignContent: Alignment.BottomStart }) {
            Image(GewuMedia.coverResource(this.item.coverKey))
              .width('100%')
              .height(220)
              .objectFit(ImageFit.Cover)
              .borderRadius({ topLeft: 0, topRight: 0, bottomLeft: Theme.radius.lg, bottomRight: Theme.radius.lg })
            Column()
              .width('100%')
              .height(220)
              .linearGradient({
                angle: 180,
                colors: [['rgba(26,58,92,0.05)', 0], ['rgba(26,58,92,0.72)', 1]]
              })
              .borderRadius({ bottomLeft: Theme.radius.lg, bottomRight: Theme.radius.lg })
            Column({ space: Theme.space.s1 }) {
              Text(`${this.item.category} · ${this.item.atlasKind}`)
                .fontSize(Theme.type.caption)
                .fontColor('#FFFFFF')
                .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                .backgroundColor('rgba(201,169,110,0.85)')
                .borderRadius(Theme.radius.pill)
              Text(this.item.title)
                .fontSize(Theme.type.title2)
                .fontWeight(FontWeight.Medium)
                .fontColor('#FFFFFF')
                .maxLines(2)
            }
            .width('100%')
            .padding({ left: Theme.space.s4, right: Theme.space.s4, bottom: Theme.space.s4 })
          }
          .width('100%')

          AppCard({ variant: 'plain', title: '摘要', onTap: (): void => {} }) {
            Text(this.item.summary)
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .lineHeight(24)
              .width('100%')
          }

          if (this.item.facts.length > 0) {
            Column({ space: Theme.space.s3 }) {
              Text('要点')
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
              ForEach(this.item.facts, (f: KnowledgeFact, idx: number) => {
                Column({ space: Theme.space.s1 }) {
                  Text(f.label)
                    .fontSize(Theme.type.bodyS)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                  Text(f.content)
                    .fontSize(Theme.type.body)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                    .lineHeight(22)
                }
                .width('100%')
                .padding(Theme.space.s3)
                .backgroundColor(Theme.colors().surfaceSubtle)
                .borderRadius(Theme.radius.md)
              }, (_f: KnowledgeFact, idx: number) => `${this.item.id}_f_${idx}`)
            }
            .width('100%')
          }

          if (this.item.timeline.length > 0) {
            Column({ space: Theme.space.s3 }) {
              Text('时间线')
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
              ForEach(this.item.timeline, (t: TimelinePoint, idx: number) => {
                Row({ space: Theme.space.s3 }) {
                  Text(t.year)
                    .fontSize(Theme.type.bodyS)
                    .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                    .width(72)
                  Text(t.event)
                    .fontSize(Theme.type.body)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                    .layoutWeight(1)
                    .lineHeight(22)
                }
                .width('100%')
                .alignItems(VerticalAlign.Top)
              }, (_t: TimelinePoint, idx: number) => `${this.item.id}_t_${idx}`)
            }
            .width('100%')
          }

          Column({ space: Theme.space.s2 }) {
            Text('正文')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            Text(this.item.body)
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .lineHeight(26)
              .width('100%')
          }
          .width('100%')

          if (KnowledgeCatalog.relatedOf(this.item.id).length > 0) {
            Column({ space: Theme.space.s2 }) {
              Text('同门类对照')
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
              ForEach(KnowledgeCatalog.relatedOf(this.item.id), (rel: KnowledgeObject) => {
                Row() {
                  Text(rel.title)
                    .fontSize(Theme.type.body)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                    .layoutWeight(1)
                  Text(rel.category)
                    .fontSize(Theme.type.caption)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                }
                .width('100%')
                .padding(Theme.space.s3)
                .backgroundColor(Theme.colors().surfaceSubtle)
                .borderRadius(Theme.radius.md)
                .onClick((): void => { GewuDetailNav.open(rel.id) })
              }, (rel: KnowledgeObject) => rel.id)
            }
            .width('100%')
          }

          InquiryNotePane({
            objectId: this.item.id,
            refreshToken: this.refreshToken,
            onDataChanged: (): void => { this.onDataChanged() }
          })

          Column({ space: Theme.space.s3 }) {
            AppButton({
              label: '写观察记录',
              variant: 'primary',
              onTap: (): void => { this.startObservation() }
            })
            if (KnowledgeCatalog.relatedKnowledge(this.item.atlasKind, this.item.id).length > 0) {
              Column({ space: Theme.space.s2 }) {
                Text('与另一物对照写笔记')
                  .fontSize(Theme.type.caption)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .width('100%')
                ForEach(KnowledgeCatalog.relatedKnowledge(this.item.atlasKind, this.item.id), (rel: KnowledgeObject) => {
                  AppButton({
                    label: `对照「${rel.title}」`,
                    variant: 'secondary',
                    onTap: (): void => { this.startCompare(rel) }
                  })
                }, (rel: KnowledgeObject) => `cmp_${rel.id}`)
              }
              .width('100%')
            }
            AppButton({
              label: this.isFavorite ? '已收藏' : '收藏',
              variant: 'secondary',
              onTap: (): void => { void this.handleFavorite() }
            })
            AppButton({
              label: this.isDeepen ? '已标记深究' : '想深究',
              variant: this.isDeepen ? 'secondary' : 'ghost',
              onTap: (): void => { void this.handleDeepen() }
            })
          }
          .width('100%')

          Column({ space: Theme.space.s2 }) {
            Text('放入收藏夹')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(AlbumKind.all(), (a: string) => {
                Text(a)
                  .fontSize(Theme.type.bodyS)
                  .fontColor(this.albumKey === a ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
                  .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                  .margin({ right: 8, bottom: 8 })
                  .backgroundColor(this.albumKey === a ?
                    Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                  .borderRadius(Theme.radius.pill)
                  .onClick((): void => { void this.handleAlbum(a) })
              }, (a: string) => a)
            }
            .width('100%')
          }
          .width('100%')

          Row().height(Theme.space.s10)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s4 })
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().brandOnPrimary)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(Theme.radius.pill)
          .position({ x: '50%', y: 48 })
          .translate({ x: '-50%' })
          .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
  }
}
