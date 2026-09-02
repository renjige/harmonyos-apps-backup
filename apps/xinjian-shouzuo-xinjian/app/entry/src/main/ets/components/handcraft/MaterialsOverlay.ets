import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppLoading } from '../design-system/AppLoading'
import { AppCard } from '../design-system/AppCard'
import { HandcraftMaterial, CreateMaterialRequest } from '../../models/HandcraftModels'
import { HandcraftBizService } from '../../services/HandcraftBizService'

@Component
export struct MaterialsOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  onClose: () => void = () => {}
  @State materials: HandcraftMaterial[] = []
  @State loading: boolean = true
  @State name: string = ''
  @State category: string = '纸艺'
  @State quantity: string = ''
  @State unit: string = '份'
  @State notes: string = ''
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout(() => { this.toastText = '' }, 2400)
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.materials = await HandcraftBizService.loadMaterials()
    this.loading = false
  }

  private async handleAdd(): Promise<void> {
    if (this.name.trim().length === 0) {
      this.showToast('请填写材料名称')
      return
    }
    const req = new CreateMaterialRequest()
    req.name = this.name.trim()
    req.category = this.category
    req.quantity = this.quantity
    req.unit = this.unit
    req.notes = this.notes
    const ok = await HandcraftBizService.createMaterial(req)
    if (ok) {
      this.name = ''
      this.quantity = ''
      this.notes = ''
      this.showToast('材料已添加')
      await this.reload()
    } else {
      this.showToast('添加失败，请稍后重试')
    }
  }

  private async handleDelete(id: string): Promise<void> {
    const ok = await HandcraftBizService.deleteMaterial(id)
    if (ok) {
      this.showToast('已删除')
      await this.reload()
    }
  }

  build() {
    Stack() {
      Column() {
        Row({ space: Theme.space.s2 }) {
          Column() {
            AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .rotate({ angle: 180 })
          .onClick((): void => { this.onClose() })
          Column({ space: 4 }) {
            Text('材料管家')
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            Text('记录手边剩余材料，创作时随时查阅')
              .fontSize(Theme.type.footnote)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          }.alignItems(HorizontalAlign.Start).layoutWeight(1)
        }
        .width('100%')
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          top: Theme.space.pageY,
          bottom: Theme.space.s3
        })
        Scroll() {
          Column({ space: Theme.space.s4 }) {
            AppCard({ title: '添加材料', variant: 'outlined' }) {
              Column({ space: Theme.space.s3 }) {
                TextInput({ text: this.name, placeholder: '材料名称' })
                  .onChange((v: string) => { this.name = v })
                TextInput({ text: this.category, placeholder: '分类（如纸艺、编织）' })
                  .onChange((v: string) => { this.category = v })
                Row({ space: Theme.space.s2 }) {
                  TextInput({ text: this.quantity, placeholder: '数量' })
                    .layoutWeight(1)
                    .onChange((v: string) => { this.quantity = v })
                  TextInput({ text: this.unit, placeholder: '单位' })
                    .width('30%')
                    .onChange((v: string) => { this.unit = v })
                }.width('100%')
                TextInput({ text: this.notes, placeholder: '备注（可选）' })
                  .onChange((v: string) => { this.notes = v })
                AppButton({
                  label: '保存到材料库',
                  variant: 'primary',
                  onTap: (): void => { void this.handleAdd() }
                })
              }.width('100%')
            }

            if (this.loading) {
              AppLoading({ label: '加载材料…' })
            } else if (this.materials.length === 0) {
              AppEmpty({ title: '暂无材料', description: '添加常用材料，方便挑战与创作时查阅' })
            } else {
              ForEach(this.materials, (m: HandcraftMaterial) => {
                AppCard({ title: m.name, variant: 'plain' }) {
                  Column({ space: 6 }) {
                    Text(`${m.category} · ${m.quantity}${m.unit}`)
                      .fontSize(Theme.type.footnote)
                      .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                    if (m.notes.length > 0) {
                      Text(m.notes)
                        .fontSize(Theme.type.caption)
                        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                    }
                    AppButton({
                      label: '删除',
                      variant: 'secondary',
                      onTap: (): void => { void this.handleDelete(m.id) }
                    })
                  }.width('100%').alignItems(HorizontalAlign.Start)
                }
              }, (m: HandcraftMaterial) => m.id)
            }
          }
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            bottom: Theme.space.s10
          })
        }
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().textOnInverse)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .position({ top: 56 })
          .zIndex(30)
      }
    }
    .width('100%')
    .height('100%')
  }
}
