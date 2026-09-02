import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppDatePickerField } from '../components/design-system/AppDatePickerField'
import { PantryListCard } from '../components/kitchenlab/PantryListCard'
import { PantryItem, PantryWriteBody } from '../models/KitchenLabModels'
import { KitchenLabBizService } from '../services/KitchenLabBizService'
import { AuthService } from '../services/AuthService'

@Component
export struct PantryPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('kitchenTick') @Watch('onKitchenTick') kitchenTick: number = 0
  @StorageLink('accessToken') accessToken: string = ''
  @State items: PantryItem[] = []
  @State categoryFilter: string = '全部'
  @State loading: boolean = true
  @State showForm: boolean = false
  @State editingId: string = ''
  @State formTitle: string = ''
  @State formCategory: string = '蔬菜'
  @State formQty: string = ''
  @State formUnit: string = ''
  @State formExpiry: string = ''
  @State formRemark: string = ''
  @State toastText: string = ''
  onRequireAuth: () => void = () => {}

  private categories: string[] = ['全部', '蔬菜', '肉类', '调味', '干货', '其他']

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
    const cat = this.categoryFilter === '全部' ? '' : this.categoryFilter
    this.items = await KitchenLabBizService.loadPantry(cat)
    this.loading = false
  }

  private daysLeft(item: PantryItem): number {
    if (item.expiryDate.length === 0) {
      return 999
    }
    return Math.ceil((new Date(item.expiryDate).getTime() - Date.now()) / 86400000)
  }

  private openAdd(): void {
    if (!AuthService.requireAuth('sync_pantry')) {
      this.onRequireAuth()
      return
    }
    this.editingId = ''
    this.formTitle = ''
    this.formCategory = '蔬菜'
    this.formQty = ''
    this.formUnit = ''
    this.formExpiry = ''
    this.formRemark = ''
    this.showForm = true
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  private openEdit(item: PantryItem): void {
    if (!AuthService.requireAuth('sync_pantry')) {
      this.onRequireAuth()
      return
    }
    this.editingId = item.id
    this.formTitle = item.title
    this.formCategory = item.category.length > 0 ? item.category : '蔬菜'
    this.formQty = item.quantity
    this.formUnit = item.unit
    this.formExpiry = item.expiryDate
    this.formRemark = item.remark
    this.showForm = true
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  private closeForm(): void {
    this.showForm = false
    AppStorage.setOrCreate('tabBarHidden', false)
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout(() => { this.toastText = '' }, 2400)
  }

  private async saveForm(): Promise<void> {
    if (this.formTitle.trim().length === 0) {
      this.showToast('请填写食材名称')
      return
    }
    const body = new PantryWriteBody()
    body.title = this.formTitle.trim()
    body.category = this.formCategory
    body.quantity = this.formQty
    body.unit = this.formUnit
    body.expiryDate = this.formExpiry
    body.remark = this.formRemark
    let ok = false
    if (this.editingId.length > 0) {
      ok = (await KitchenLabBizService.updatePantry(this.editingId, body)) !== undefined
    } else {
      ok = (await KitchenLabBizService.createPantry(body)) !== undefined
    }
    if (ok) {
      this.closeForm()
      await this.reload()
      this.showToast('已保存')
    } else {
      this.showToast('保存失败')
    }
  }

  build() {
    Stack() {
      Column() {
        AppHeader({ title: '食材', subtitle: '管理库存与保质期' })
        Scroll() {
          Row({ space: Theme.space.s2 }) {
            ForEach(this.categories, (c: string) => {
              Text(c)
                .fontSize(Theme.type.caption)
                .fontColor(this.categoryFilter === c ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
                .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                .backgroundColor(this.categoryFilter === c ?
                  Theme.colors().brandPrimary : Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.pill)
                .border({ width: 1, color: Theme.colors().strokeHairline })
                .onClick(() => {
                  this.categoryFilter = c
                  void this.reload()
                })
            }, (c: string) => c)
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s3 })
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
        .width('100%')

        if (!this.isLoggedIn()) {
          AppEmpty({
            title: '登录后同步食材',
            description: '游客可浏览菜谱；录入食材与保质期需登录',
            actionLabel: '去登录',
            onAction: (): void => this.onRequireAuth()
          }).layoutWeight(1)
        } else if (this.loading) {
          Text('加载中…')
            .fontSize(Theme.type.body)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .layoutWeight(1)
        } else if (this.items.length === 0) {
          AppEmpty({
            title: '暂无食材',
            description: '点击右下角添加第一条库存',
            actionLabel: '添加食材',
            onAction: (): void => this.openAdd()
          }).layoutWeight(1)
        } else {
          Scroll() {
            Grid() {
              ForEach(this.items, (p: PantryItem) => {
                GridItem() {
                  PantryListCard({
                    item: p,
                    daysLeft: this.daysLeft(p),
                    onTap: (): void => this.openEdit(p)
                  })
                }
              }, (p: PantryItem) => p.id)
            }
            .columnsTemplate('1fr 1fr')
            .columnsGap(Theme.space.s3)
            .rowsGap(Theme.space.s3)
            .padding({
              left: Theme.space.pageX,
              right: Theme.space.pageX,
              bottom: Theme.space.s10
            })
            .width('100%')
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring)
        }

        if (this.isLoggedIn()) {
          Row() {
            AppButton({ label: '添加食材', onTap: (): void => this.openAdd() })
          }
          .width('100%')
          .padding(Theme.space.pageX)
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.showForm) {
        Column({ space: Theme.space.s4 }) {
          Text(this.editingId.length > 0 ? '编辑食材' : '添加食材')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          TextInput({ text: this.formTitle, placeholder: '食材名称' })
            .height(48)
            .padding({ left: 12, right: 12 })
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.sm)
            .onChange((v: string) => { this.formTitle = v })
          TextInput({ text: this.formCategory, placeholder: '分类' })
            .height(48)
            .padding({ left: 12, right: 12 })
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.sm)
            .onChange((v: string) => { this.formCategory = v })
          Row({ space: Theme.space.s3 }) {
            TextInput({ text: this.formQty, placeholder: '数量' })
              .layoutWeight(1)
              .height(48)
              .padding({ left: 12, right: 12 })
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.sm)
              .onChange((v: string) => { this.formQty = v })
            TextInput({ text: this.formUnit, placeholder: '单位' })
              .layoutWeight(1)
              .height(48)
              .padding({ left: 12, right: 12 })
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.sm)
              .onChange((v: string) => { this.formUnit = v })
          }
          .width('100%')
          AppDatePickerField({
            label: '保质期',
            value: this.formExpiry,
            placeholder: '选择到期日',
            minDaysFromToday: -365,
            maxDaysFromToday: 730,
            onChange: (v: string): void => { this.formExpiry = v }
          })
          TextInput({ text: this.formRemark, placeholder: '备注（选填）' })
            .height(48)
            .padding({ left: 12, right: 12 })
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.sm)
            .onChange((v: string) => { this.formRemark = v })
          Row({ space: Theme.space.s3 }) {
            AppButton({ label: '取消', variant: 'secondary', onTap: (): void => this.closeForm() })
              .layoutWeight(1)
            AppButton({ label: '保存', onTap: (): void => { void this.saveForm() } })
              .layoutWeight(1)
          }
          .width('100%')
        }
        .width('100%')
        .height('100%')
        .padding(Theme.space.pageX)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
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
