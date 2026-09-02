import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { DetailShell } from './DetailShell'
import { RenoDates, RenoMaterial } from '../../models/RenoModels'

@Component
export struct MaterialDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: RenoMaterial = new RenoMaterial()
  onClose: () => void = () => {}
  onEdit: () => void = () => {}
  onDelete: () => void = () => {}

  private line(label: string, value: string): string {
    return `${label}：${value.length > 0 ? value : '未填写'}`
  }

  build() {
    DetailShell({
      title: this.item.title,
      coverKey: 'stage_wood',
      onBack: () => this.onClose()
    }) {
      Column({ space: Theme.space.s4 }) {
        Text(RenoDates.materialLabel(this.item.status))
          .fontSize(Theme.type.footnote)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          .width('100%')
        Column({ space: 8 }) {
          Text(this.line('品牌', this.item.brand))
          Text(this.line('型号', this.item.model))
          Text(this.line('规格', this.item.spec))
          Text(this.line('数量', this.item.qty))
          Text(this.line('房间', this.item.room))
        }
        .width('100%')
        .padding(Theme.space.s4)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.md)
        .alignItems(HorizontalAlign.Start)
        Text(this.item.remark.length > 0 ? this.item.remark : '轻量材料清单，用于记住规格与状态，不是库存系统。')
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        AppButton({ label: '编辑材料', onTap: () => this.onEdit() })
        AppButton({ label: '删除材料', variant: 'danger', onTap: () => this.onDelete() })
      }
      .width('100%')
    }
  }
}
