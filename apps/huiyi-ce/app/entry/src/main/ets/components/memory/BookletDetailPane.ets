import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { AppEmpty } from '../design-system/AppEmpty'
import { MemoryBooklet, MemoryRecord } from '../../models/MemoryModels'
import { MemoryStore } from '../../services/MemoryStore'
import { ExportService } from '../../services/ExportService'
import { MemoryListCard } from './MemoryListCard'
import { common } from '@kit.AbilityKit'

@Component
export struct BookletDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop bookletId: string = ''
  @Prop @Watch('onReloadTokenChange') reloadToken: number = 0
  @State book: MemoryBooklet = new MemoryBooklet()
  @State items: MemoryRecord[] = []
  @State confirmDelete: boolean = false
  @State toastText: string = ''
  private uiContext: common.UIAbilityContext | null = null
  onClose: () => void = () => {}
  onChanged: () => void = () => {}
  onOpenDetail: (id: string) => void = (_id: string) => {}
  onEditBooklet: (id: string) => void = (_id: string) => {}
  onPickRecord: (bookletId: string) => void = (_id: string) => {}

  aboutToAppear(): void {
    void this.load()
  }

  onReloadTokenChange(): void {
    void this.load()
  }

  private async load(): Promise<void> {
    const found = await MemoryStore.findBooklet(this.bookletId)
    if (found !== undefined) {
      this.book = found
      this.items = await MemoryStore.recordsOfBooklet(found.id)
    }
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2200)
  }

  private async doDelete(): Promise<void> {
    if (!this.confirmDelete) {
      this.confirmDelete = true
      this.showToast('再点一次确认删除这本册')
      return
    }
    await MemoryStore.deleteBooklet(this.book.id)
    this.onChanged()
    this.onClose()
  }

  private async exportBook(): Promise<void> {
    if (this.uiContext === null) {
      this.showToast('导出环境未就绪')
      return
    }
    try {
      const path = await ExportService.exportBooklet(this.uiContext, this.book.id)
      this.showToast(`已导出：${path}`)
    } catch {
      this.showToast('导出失败')
    }
  }

  private async removeItem(id: string): Promise<void> {
    await MemoryStore.removeFromBooklet(this.book.id, id)
    await this.load()
    this.onChanged()
    this.showToast('已移出本册')
  }

  build() {
    Stack() {
      Column() {
        Row() {
          Row() {
            AppIcon({ name: 'close', iconSize: Theme.icon.lg, color: Theme.colors().textPrimary })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .onClick((): void => { this.onClose() })
          Blank()
          Text('记忆册')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          Blank()
          Column().width(44)
        }
        .width('100%')
        .padding(Theme.space.pageX)

        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Stack({ alignContent: Alignment.BottomStart }) {
              Image($r('app.media.classify_tabs'))
                .width('100%')
                .height(160)
                .objectFit(ImageFit.Cover)
              Column() {
                Blank()
                Column({ space: 6 }) {
                  Text(this.book.title.length > 0 ? this.book.title : '未命名册')
                    .fontSize(Theme.type.title3)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#FFFFFF')
                  Text(this.book.countLabel())
                    .fontSize(Theme.type.bodyS)
                    .fontColor('#FFFFFF')
                }
                .width('100%')
                .padding(Theme.space.s4)
                .linearGradient({
                  angle: 180,
                  colors: [['rgba(0,0,0,0)', 0], ['rgba(11,42,92,0.82)', 1]]
                })
              }
              .width('100%')
              .height(160)
            }
            .width('100%')
            .height(160)
            .borderRadius(Theme.radius.md)
            .clip(true)

            Text(this.book.summary.length > 0 ? this.book.summary : '把同一主题的记忆收进这本册，方便整本回顾。')
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')

            AppButton({
              label: '添加记忆进册',
              onTap: (): void => { this.onPickRecord(this.book.id) }
            })
            AppButton({
              label: '编辑册名',
              variant: 'secondary',
              onTap: (): void => { this.onEditBooklet(this.book.id) }
            })
            AppButton({
              label: '导出本册 txt',
              variant: 'secondary',
              onTap: (): void => { void this.exportBook() }
            })

            if (this.items.length === 0) {
              AppEmpty({
                title: '册里还没有记忆',
                description: '点「添加记忆进册」，把已写下的内容收进来'
              })
            } else {
              ForEach(this.items, (it: MemoryRecord) => {
                Column({ space: Theme.space.s2 }) {
                  MemoryListCard({
                    item: it,
                    onOpen: (): void => { this.onOpenDetail(it.id) }
                  })
                  Text('移出本册')
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().danger)
                    .width('100%')
                    .onClick((): void => { void this.removeItem(it.id) })
                }
              }, (it: MemoryRecord) => it.id)
            }

            AppButton({
              label: this.confirmDelete ? '再点一次确认删除' : '删除这本册',
              variant: 'danger',
              onTap: (): void => { void this.doDelete() }
            })
          }
          .width('100%')
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            bottom: Theme.space.s10
          })
        }
        .layoutWeight(1)
        .edgeEffect(EdgeEffect.Spring)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor('#FFFFFF')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .position({ x: '24%', y: 48 })
          .zIndex(80)
      }
    }
    .width('100%')
    .height('100%')
    .onAppear((): void => {
      AppStorage.setOrCreate('tabBarHidden', true)
      const host = this.getUIContext().getHostContext()
      if (host !== undefined) {
        this.uiContext = host as common.UIAbilityContext
      }
    })
    .onDisAppear((): void => {
      AppStorage.setOrCreate('tabBarHidden', false)
    })
  }
}
