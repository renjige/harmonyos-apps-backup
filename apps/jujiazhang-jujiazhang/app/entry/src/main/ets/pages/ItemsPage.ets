import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { ChoiceChip } from '../components/family/ChoiceChip'
import { ItemRow } from '../components/jujia/ItemRow'
import { MaintenanceFormOverlay } from '../components/jujia/MaintenanceFormOverlay'
import { HomeItem, MaintenanceJob } from '../models/JujiaModels'
import { ItemService } from '../services/ItemService'
import { MaintenanceService } from '../services/MaintenanceService'
import { common } from '@kit.AbilityKit'
import { ReminderService } from '../services/ReminderService'

@Component
export struct ItemsPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State items: HomeItem[] = []
  @State maintenance: MaintenanceJob[] = []
  @State segment: string = 'items'
  @State showMaintForm: boolean = false
  @State maintEdit: boolean = false
  @State maintSeed: MaintenanceJob = new MaintenanceJob()
  @State toastText: string = ''
  @Prop @Watch('onTick') refreshToken: number = 0
  onOpen: (item: HomeItem) => void = (_i: HomeItem) => {}
  onAdd: () => void = () => {}

  aboutToAppear(): void {
    void this.reload()
  }

  onTick(): void {
    void this.reload()
  }

  async reload(): Promise<void> {
    this.items = await ItemService.list()
    this.maintenance = await MaintenanceService.list()
  }

  private host(): common.UIAbilityContext {
    return this.getUIContext().getHostContext() as common.UIAbilityContext
  }

  private toast(msg: string): void {
    this.toastText = msg
    setTimeout(() => { this.toastText = '' }, 2200)
  }

  build() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      Column() {
        Text('家庭物品')
          .fontSize(Theme.type.titleM)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s5 })
        Row({ space: 8 }) {
          ChoiceChip({ label: '物品档案', active: this.segment === 'items', onPick: () => { this.segment = 'items' } })
          ChoiceChip({ label: '维护提醒', active: this.segment === 'maint', onPick: () => { this.segment = 'maint' } })
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: 8 })

        Scroll() {
          Column({ space: Theme.space.s4 }) {
            if (this.segment === 'items') {
              Text('登记保修期、有效期与存放位置，到期前系统提醒。')
                .fontSize(Theme.type.bodyS)
                .fontColor(Theme.colors().textSecondary)
                .width('100%')
              if (this.items.length === 0) {
                AppEmpty({
                  title: '还没有登记物品',
                  description: '把家电保修、药品有效期、证件到期日记在这里。',
                  actionLabel: '登记第一件',
                  onAction: () => this.onAdd()
                })
              } else {
                ForEach(this.items, (row: HomeItem) => {
                  ItemRow({ item: row, onTap: () => this.onOpen(row) })
                }, (row: HomeItem) => row.id)
              }
            } else {
              Text('清洗空调、更换滤芯等设备维护，按周期到期提醒。')
                .fontSize(Theme.type.bodyS)
                .fontColor(Theme.colors().textSecondary)
                .width('100%')
              if (this.maintenance.length === 0) {
                AppEmpty({
                  title: '还没有维护项目',
                  description: '添加定期维护任务，到期推送系统通知。',
                  actionLabel: '添加维护',
                  onAction: () => { this.maintEdit = false; this.maintSeed = new MaintenanceJob(); this.showMaintForm = true; AppStorage.setOrCreate('tabBarHidden', true) }
                })
              } else {
                ForEach(this.maintenance, (job: MaintenanceJob) => {
                  Row() {
                    Column({ space: 4 }) {
                      Text(job.title).fontSize(Theme.type.body).fontColor(Theme.colors().textPrimary).width('100%')
                      Text(`${job.room} · 下次 ${job.nextDueDate}`).fontSize(Theme.type.caption).fontColor(Theme.colors().textSecondary).width('100%')
                    }.layoutWeight(1).alignItems(HorizontalAlign.Start)
                    Text('完成')
                      .fontSize(Theme.type.caption)
                      .fontColor(Theme.colors().brandOnPrimary)
                      .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                      .backgroundColor(Theme.colors().brandPrimary)
                      .borderRadius(Theme.radius.sm)
                      .onClick(() => { void MaintenanceService.markDone(job.id).then(() => { void this.reload(); this.toast('已记录维护') }) })
                  }
                  .width('100%').padding(14).backgroundColor(Theme.colors().surfaceCard).borderRadius(Theme.radius.lg)
                }, (job: MaintenanceJob) => job.id)
              }
            }
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: 96 })
        }
        .layoutWeight(1).scrollBar(BarState.Off)
      }
      .width('100%').height('100%').backgroundColor(Theme.colors().surfacePage)

      Column() {
        Row({ space: 6 }) {
          AppIcon({ name: 'add', iconSize: 18, color: Theme.colors().brandOnPrimary })
          Text(this.segment === 'items' ? '登记物品' : '添加维护')
            .fontSize(Theme.type.body).fontWeight(FontWeight.Medium).fontColor(Theme.colors().brandOnPrimary)
        }
      }
      .height(48).padding({ left: 18, right: 20 }).backgroundColor(Theme.colors().brandPrimary)
      .borderRadius(Theme.radius.button).margin({ right: 20, bottom: 12 }).justifyContent(FlexAlign.Center)
      .onClick(() => {
        if (this.segment === 'items') {
          this.onAdd()
          return
        }
        this.maintEdit = false
        this.maintSeed = new MaintenanceJob()
        this.showMaintForm = true
        AppStorage.setOrCreate('tabBarHidden', true)
      })

      if (this.showMaintForm) {
        MaintenanceFormOverlay({
          isEdit: this.maintEdit,
          seed: this.maintSeed,
          onClose: () => { this.showMaintForm = false; AppStorage.setOrCreate('tabBarHidden', false) },
          onSave: (d: MaintenanceJob) => { void this.saveMaint(d) }
        })
      }

      if (this.toastText.length > 0) {
        Text(this.toastText).fontSize(Theme.type.caption).fontColor(Theme.colors().brandOnPrimary)
          .padding({ left: 14, right: 14, top: 8, bottom: 8 }).backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(Theme.radius.sm).margin({ top: 40 }).zIndex(30)
      }
    }.width('100%').height('100%')
  }

  private async saveMaint(draft: MaintenanceJob): Promise<void> {
    let row: MaintenanceJob
    if (this.maintEdit && draft.id.length > 0) {
      row = MaintenanceService.clone(draft)
      row.nextDueDate = MaintenanceService.nextDueFrom(row.lastDoneDate, row.cycleDays)
      await MaintenanceService.update(row)
    } else {
      row = await MaintenanceService.create(draft)
    }
    await ReminderService.scheduleMaintenance(row, this.host())
    this.showMaintForm = false
    AppStorage.setOrCreate('tabBarHidden', false)
    await this.reload()
    this.toast(ReminderService.lastAction.length > 0 ? ReminderService.lastAction : '维护提醒已添加')
  }
}
