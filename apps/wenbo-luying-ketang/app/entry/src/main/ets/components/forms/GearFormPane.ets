import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { CampBizService } from '../../services/CampBizService'
import { CampDetailNav } from '../../services/CampDetailNav'
import { CampWriteRequest } from '../../models/CampModels'
import { DetailShell } from '../detail/DetailShell'

@Component
export struct GearFormPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop editId: string = ''
  @State title: string = ''
  @State category: string = '帐篷'
  @State weightText: string = ''
  @State errorText: string = ''
  @State saving: boolean = false
  private cats: string[] = ['帐篷', '睡眠', '炊具', '照明', '穿着', '工具']

  private async save(): Promise<void> {
    if (this.title.trim().length === 0) {
      this.errorText = '请填写装备名称'
      return
    }
    const w = Number.parseInt(this.weightText, 10)
    if (Number.isNaN(w) || w < 0) {
      this.errorText = '请填写克重（整数）'
      return
    }
    this.saving = true
    const body = new CampWriteRequest()
    body.title = this.title.trim()
    body.category = this.category
    body.weightG = w
    let ok = false
    if (this.editId.length > 0) {
      ok = await CampBizService.update('gear', this.editId, body)
    } else {
      ok = await CampBizService.create('gear', body)
    }
    this.saving = false
    if (ok) {
      CampDetailNav.close()
      return
    }
    this.errorText = '保存失败'
  }

  private async remove(): Promise<void> {
    if (this.editId.length === 0) {
      return
    }
    const ok = await CampBizService.remove('gear', this.editId)
    if (ok) {
      CampDetailNav.close()
    }
  }

  build() {
    DetailShell({ title: this.editId.length > 0 ? '编辑装备' : '新增装备', onClose: () => CampDetailNav.close() }) {
      Column({ space: 12 }) {
        if (this.errorText.length > 0) {
          Text(this.errorText)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().danger)
            .width('100%')
        }
        TextInput({ text: this.title, placeholder: '装备名称' })
          .onChange((v: string) => { this.title = v })
        Text('分类')
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(this.cats, (c: string) => {
            Text(c)
              .fontSize(Theme.type.caption)
              .fontColor(this.category === c ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
              .padding({ left: 12, right: 12, top: 8, bottom: 8 })
              .margin({ right: 8, bottom: 8 })
              .backgroundColor(this.category === c ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.pill)
              .onClick(() => { this.category = c })
          }, (c: string) => c)
        }
        TextInput({ text: this.weightText, placeholder: '重量（克）' })
          .onChange((v: string) => { this.weightText = v })
        AppButton({ label: this.saving ? '保存中…' : '保存', onTap: () => { void this.save() } })
        if (this.editId.length > 0) {
          AppButton({ label: '删除这件装备', variant: 'danger', onTap: () => { void this.remove() } })
        }
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      .width('100%')
    }
  }
}
