import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { ShoppingItem, ShoppingWriteBody } from '../models/KitchenLabModels'
import { KitchenLabBizService } from '../services/KitchenLabBizService'
import { AuthService } from '../services/AuthService'
import { pasteboard } from '@kit.BasicServicesKit'

@Component
export struct ShoppingPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('kitchenTick') @Watch('onKitchenTick') kitchenTick: number = 0
  @StorageLink('accessToken') accessToken: string = ''
  @State items: ShoppingItem[] = []
  @State loading: boolean = true
  @State showAdd: boolean = false
  @State newTitle: string = ''
  @State newQty: string = ''
  @State toastText: string = ''
  onRequireAuth: () => void = () => {}

  aboutToAppear(): void {
    void this.reload()
  }

  onKitchenTick(): void {
    void this.reload()
  }

  private isLoggedIn(): boolean {
    return this.accessToken.length > 0
  }

  private async reload(): Promise<void> {
    if (!this.isLoggedIn()) {
      this.items = []
      this.loading = false
      return
    }
    this.loading = true
    this.items = await KitchenLabBizService.loadShopping()
    this.loading = false
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout(() => { this.toastText = '' }, 2400)
  }

  private async toggleCheck(item: ShoppingItem): Promise<void> {
    const body = new ShoppingWriteBody()
    body.title = item.title
    body.qty = item.qty
    body.unit = item.unit
    body.isChecked = !item.isChecked
    body.remark = item.remark
    await KitchenLabBizService.updateShopping(item.id, body)
    await this.reload()
  }

  private async addItem(): Promise<void> {
    if (!AuthService.requireAuth('sync_shopping')) {
      this.onRequireAuth()
      return
    }
    if (this.newTitle.trim().length === 0) {
      this.showToast('请填写名称')
      return
    }
    const body = new ShoppingWriteBody()
    body.title = this.newTitle.trim()
    body.qty = this.newQty
    const row = await KitchenLabBizService.createShopping(body)
    if (row !== undefined) {
      this.newTitle = ''
      this.newQty = ''
      this.showAdd = false
      await this.reload()
      this.showToast('已添加')
    }
  }

  private shareText(): void {
    const lines: string[] = ['【厨验Lab 采购清单】']
    for (let s of this.items) {
      const mark = s.isChecked ? '[x]' : '[ ]'
      lines.push(`${mark} ${s.title}${s.qty.length > 0 ? ' ' + s.qty : ''}`)
    }
    const text = lines.join('\n')
    try {
      const data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, text)
      pasteboard.getSystemPasteboard().setData(data)
      this.showToast('清单已复制到剪贴板')
    } catch {
      this.showToast('请手动复制清单内容')
    }
  }

  build() {
    Stack() {
      Column() {
        AppHeader({ title: '采购', subtitle: '勾选采购项并分享' })
        if (!this.isLoggedIn()) {
          AppEmpty({
            title: '登录后同步采购清单',
            description: '从菜谱一键加入或手动添加采购项',
            actionLabel: '去登录',
            onAction: (): void => this.onRequireAuth()
          }).layoutWeight(1)
        } else if (this.loading) {
          Text('加载中…').layoutWeight(1)
        } else if (this.items.length === 0) {
          AppEmpty({
            title: '采购清单为空',
            description: '在菜谱详情可一键加入食材',
            actionLabel: '手动添加',
            onAction: (): void => { this.showAdd = true }
          }).layoutWeight(1)
        } else {
          Scroll() {
            Column({ space: Theme.space.s2 }) {
              ForEach(this.items, (s: ShoppingItem) => {
                Row({ space: Theme.space.s3 }) {
                  Row() {
                    if (s.isChecked) {
                      AppIcon({ name: 'check', iconSize: Theme.icon.sm, color: Theme.colors().brandOnPrimary })
                    }
                  }
                  .width(24)
                  .height(24)
                  .justifyContent(FlexAlign.Center)
                  .borderRadius(Theme.radius.xs)
                  .backgroundColor(s.isChecked ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
                  .border({ width: 1, color: Theme.colors().strokeStrong })
                  Column({ space: 2 }) {
                    Text(s.title)
                      .fontSize(Theme.type.body)
                      .fontColor(s.isChecked ? Theme.colors().textTertiary : Theme.colors().textPrimary)
                      .decoration({ type: s.isChecked ? TextDecorationType.LineThrough : TextDecorationType.None })
                    if (s.qty.length > 0) {
                      Text(s.qty)
                        .fontSize(Theme.type.caption)
                        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                    }
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Start)
                }
                .width('100%')
                .padding(Theme.space.s4)
                .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.lg)
                .onClick((): void => { void this.toggleCheck(s) })
              }, (s: ShoppingItem) => s.id)
            }
            .padding({
              left: Theme.space.pageX,
              right: Theme.space.pageX,
              bottom: Theme.space.s10
            })
            .width('100%')
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
        }

        if (this.isLoggedIn()) {
          Row({ space: Theme.space.s3 }) {
            AppButton({ label: '添加', variant: 'secondary', onTap: (): void => { this.showAdd = true } })
              .layoutWeight(1)
            AppButton({ label: '分享清单', onTap: (): void => this.shareText() })
              .layoutWeight(1)
          }
          .width('100%')
          .padding(Theme.space.pageX)
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.showAdd) {
        Column({ space: Theme.space.s4 }) {
          Text('添加采购项')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
          TextInput({ text: this.newTitle, placeholder: '名称' })
            .height(48)
            .padding({ left: 12, right: 12 })
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.sm)
            .onChange((v: string) => { this.newTitle = v })
          TextInput({ text: this.newQty, placeholder: '数量（选填）' })
            .height(48)
            .padding({ left: 12, right: 12 })
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.sm)
            .onChange((v: string) => { this.newQty = v })
          Row({ space: Theme.space.s3 }) {
            AppButton({ label: '取消', variant: 'secondary', onTap: (): void => { this.showAdd = false } })
              .layoutWeight(1)
            AppButton({ label: '添加', onTap: (): void => { void this.addItem() } })
              .layoutWeight(1)
          }
          .width('100%')
        }
        .width('100%')
        .height('100%')
        .padding(Theme.space.pageX)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
        .justifyContent(FlexAlign.Center)
      }

      if (this.toastText.length > 0) {
        Column() {
          Text(this.toastText)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().brandOnPrimary)
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor(Theme.colors().brandPrimary)
            .borderRadius(Theme.radius.pill)
        }
        .width('100%')
        .padding({ top: Theme.space.s6 })
        .alignItems(HorizontalAlign.Center)
        .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
  }
}
