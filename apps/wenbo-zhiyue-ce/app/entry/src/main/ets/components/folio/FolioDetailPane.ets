import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppCard } from '../design-system/AppCard'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppIcon } from '../design-system/AppIcon'
import { ExcerptItem, KnowledgeFolio } from '../../models/FolioModels'
import { FolioStore } from '../../services/FolioStore'
import { FolioMedia } from '../../services/FolioMedia'
import { DetailShell } from '../detail/DetailShell'
import { ExcerptListCard } from '../read/ListCards'

@Component
export struct FolioDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onIdChange') folioId: string = ''
  @StorageLink('folioEpoch') @Watch('onEpoch') folioEpoch: number = 0
  @State item: KnowledgeFolio = new KnowledgeFolio()
  @State excerpts: ExcerptItem[] = []
  @State confirmDelete: boolean = false
  @State toastText: string = ''
  onClose: () => void = () => {}
  onChanged: () => void = () => {}
  onEdit: (id: string) => void = (_id: string) => {}
  onWriteExcerpt: (id: string) => void = (_id: string) => {}
  onOpenExcerpt: (id: string) => void = (_id: string) => {}

  aboutToAppear(): void {
    void this.load()
  }

  onIdChange(): void {
    void this.load()
  }

  onEpoch(): void {
    void this.load()
  }

  private async load(): Promise<void> {
    const found = await FolioStore.findFolio(this.folioId)
    if (found !== undefined) {
      this.item = found
    }
    this.excerpts = await FolioStore.excerptsOfFolio(this.folioId)
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2000)
  }

  private openEdit(): void {
    this.onEdit(this.item.id)
  }

  private openWrite(): void {
    this.onWriteExcerpt(this.item.id)
  }

  private async doDelete(): Promise<void> {
    if (!this.confirmDelete) {
      this.confirmDelete = true
      this.showToast('再点一次确认删除知识册（摘录会保留）')
      return
    }
    await FolioStore.deleteFolio(this.item.id)
    this.onChanged()
    this.onClose()
  }

  build() {
    Stack() {
      DetailShell({
        title: '知识册',
        onClose: (): void => { this.onClose() }
      }) {
        Scroll() {
          Column({ space: 12 }) {
            Stack() {
              Image(FolioMedia.cover(this.item.coverKey))
                .width('100%')
                .height(180)
                .objectFit(ImageFit.Cover)
              Column() {
                Text(FolioMedia.coverLabel(this.item.coverKey))
                  .fontSize(Theme.type.caption)
                  .fontColor('#FFFFFF')
                Text(this.item.title)
                  .fontSize(Theme.type.title3)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#FFFFFF')
                  .margin({ top: 4 })
              }
              .width('100%')
              .padding(16)
              .linearGradient({
                angle: 180,
                colors: [['rgba(45,62,80,0)', 0], ['rgba(27,40,56,0.86)', 1]]
              })
              Row() {
                Blank()
                Row() {
                  AppIcon({ name: 'edit', iconSize: Theme.icon.sm, color: Theme.colors().brandPrimary })
                  Text('编辑')
                    .fontSize(Theme.type.caption)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                    .margin({ left: 4 })
                }
                .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                .backgroundColor('#FFFFFF')
                .borderRadius(Theme.radius.pill)
                .onClick((): void => { this.openEdit() })
              }
              .width('100%')
              .padding({ right: 12, top: 12 })
            }
            .width('100%')
            .height(180)
            .borderRadius(Theme.radius.card)
            .clip(true)

            AppCard({ title: '简介' }) {
              Text(this.item.summary.length > 0 ? this.item.summary : '还没有简介，点右上角「编辑」补充。')
                .fontSize(Theme.type.body)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')
            }

            Row({ space: 8 }) {
              Column() {
                AppButton({
                  label: '编辑知识册',
                  variant: 'secondary',
                  onTap: (): void => { this.openEdit() }
                })
              }
              .layoutWeight(1)
              Column() {
                AppButton({
                  label: '写入摘录',
                  onTap: (): void => { this.openWrite() }
                })
              }
              .layoutWeight(1)
            }
            .width('100%')

            Text(`册内摘录 ${this.excerpts.length} 条`)
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')

            if (this.excerpts.length === 0) {
              AppEmpty({
                title: '这本知识册还是空的',
                description: '自检会为你建好主题册，接下来写入第一条摘录即可开始整理',
                actionLabel: '写入第一条摘录',
                onAction: (): void => { this.openWrite() }
              })
            } else {
              ForEach(this.excerpts, (it: ExcerptItem) => {
                ExcerptListCard({
                  quote: it.text,
                  meta: it.tagLine(),
                  favorite: it.isFavorite,
                  onTap: (): void => { this.onOpenExcerpt(it.id) }
                })
              }, (it: ExcerptItem) => it.id)
            }

            AppButton({
              label: this.confirmDelete ? '再点一次确认删除' : '删除知识册',
              variant: 'danger',
              onTap: (): void => { void this.doDelete() }
            })
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
          .width('100%')
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.footnote)
          .fontColor('#FFFFFF')
          .padding({ left: 16, right: 16, top: 8, bottom: 8 })
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(Theme.radius.pill)
          .margin({ top: 48 })
      }
    }
    .width('100%')
    .height('100%')
  }
}
