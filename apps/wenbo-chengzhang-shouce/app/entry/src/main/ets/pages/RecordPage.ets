import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { AppIcon } from '../components/design-system/AppIcon'
import { GrowthListCard } from '../components/growth/GrowthListCard'
import { RecordEditorSheet } from '../components/growth/RecordEditorSheet'
import { GrowthRecordItem } from '../models/GrowthModels'
import { GrowthBizService } from '../services/GrowthBizService'
import { GrowthDetailNav } from '../services/GrowthDetailNav'
import { AuthService } from '../services/AuthService'

@Component
export struct RecordPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onCreateTriggerChange') createTrigger: number = 0
  onRequireAuth: () => void = () => {}
  onRecordCreated: () => void = () => {}
  @State records: GrowthRecordItem[] = []
  @State loading: boolean = true
  @State showForm: boolean = false
  @StorageLink('currentUsername') currentUsername: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onCreateTriggerChange(): void {
    if (this.createTrigger > 0) {
      this.openCreateForm()
    }
  }

  private async reload(): Promise<void> {
    this.loading = true
    if (AuthService.isLoggedIn()) {
      this.records = await GrowthBizService.loadRecords(this.currentUsername)
    } else {
      this.records = []
    }
    this.loading = false
  }

  private openCreateForm(): void {
    if (!AuthService.requireAuth('create_record')) {
      this.onRequireAuth()
      return
    }
    this.showForm = true
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  private closeForm(): void {
    this.showForm = false
    AppStorage.setOrCreate('tabBarHidden', false)
  }

  private async handleSaved(): Promise<void> {
    await this.reload()
    this.onRecordCreated()
  }

  build() {
    Stack() {
      Column() {
        AppHeader({ title: '成长记录', subtitle: '记录突破、感受与日常观察' })
        if (this.loading) {
          AppLoading({ label: '加载记录…' }).layoutWeight(1)
        } else if (this.records.length === 0) {
          Column() {
            AppEmpty({
              title: '还没有成长记录',
              description: AuthService.isLoggedIn()
                ? '点击右下角按钮，写下第一条成长'
                : '登录后可创建并同步你的成长记录',
              actionLabel: '记录成长',
              onAction: (): void => { this.openCreateForm() }
            })
          }
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        } else {
          Scroll() {
            Column({ space: Theme.space.s3 }) {
              ForEach(this.records, (item: GrowthRecordItem) => {
                GrowthListCard({
                  item: item,
                  onTap: (): void => { GrowthDetailNav.openInspiration(item.id) }
                })
              }, (item: GrowthRecordItem) => item.id)
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
          .edgeEffect(EdgeEffect.Spring)
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (!this.showForm) {
        Column() {
          AppIcon({ name: 'add', iconSize: Theme.icon.lg, color: Theme.colors().brandOnPrimary })
        }
        .width(56)
        .height(56)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(Theme.colors().brandPrimary)
        .borderRadius(Theme.radius.pill)
        .shadow({ radius: 12, color: 'rgba(27,42,65,0.2)', offsetY: 4 })
        .position({ x: '78%', y: '82%' })
        .onClick((): void => { this.openCreateForm() })
      }

      if (this.showForm) {
        RecordEditorSheet({
          mode: 'create',
          allRecords: this.records,
          onClose: (): void => { this.closeForm() },
          onSaved: (): void => { void this.handleSaved() },
          onRequireAuth: (): void => { this.onRequireAuth() }
        })
      }
    }
    .width('100%')
    .height('100%')
  }
}
