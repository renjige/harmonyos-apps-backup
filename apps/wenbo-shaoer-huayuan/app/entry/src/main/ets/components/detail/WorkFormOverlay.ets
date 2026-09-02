import { common } from '@kit.AbilityKit'
import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppDatePickerField } from '../design-system/AppDatePickerField'
import { ArtworkWriteRequest } from '../../models/KagModels'
import { KagBizService } from '../../services/KagBizService'
import { KagNav } from '../../services/KagNav'
import { PhotoPickService } from '../../services/PhotoPickService'
import { DetailShell } from './DetailShell'

@Component
export struct WorkFormOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('kagChildId') childId: string = ''
  @State photos: string[] = []
  @State title: string = ''
  @State createdOn: string = KagBizService.today()
  @State ageLabel: string = ''
  @State story: string = ''
  @State errorText: string = ''
  @State saving: boolean = false

  private async addPhotos(): Promise<void> {
    const host = this.getUIContext().getHostContext()
    if (host === undefined) {
      return
    }
    const ctx = host as common.UIAbilityContext
    const remain = 9 - this.photos.length
    const added = await PhotoPickService.pickMany(ctx, remain)
    const next: string[] = []
    for (const u of this.photos) {
      next.push(u)
    }
    for (const u of added) {
      next.push(u)
    }
    this.photos = next
    if (this.title.length === 0 && next.length > 0) {
      this.title = '未命名作品'
    }
  }

  private async save(): Promise<void> {
    if (this.saving) {
      return
    }
    if (this.photos.length === 0) {
      this.errorText = '请先从相册选择画作照片'
      return
    }
    if (this.title.trim().length === 0) {
      this.errorText = '请填写作品名称'
      return
    }
    this.saving = true
    let okAll = true
    let n = 0
    for (const photo of this.photos) {
      n++
      const body = new ArtworkWriteRequest()
      if (this.photos.length === 1) {
        body.title = this.title.trim()
      } else {
        body.title = `${this.title.trim()} ${n}`
      }
      body.createdOn = this.createdOn
      body.ageLabel = this.ageLabel
      body.story = this.story
      body.childId = this.childId
      body.imageFile = photo
      body.coverKey = 'empty_easel'
      const ok = await KagBizService.createWork(body)
      if (!ok) {
        okAll = false
      }
    }
    this.saving = false
    if (okAll) {
      KagNav.bump()
      KagNav.close()
      return
    }
    this.errorText = '部分作品未保存，请检查网络后重试'
  }

  build() {
    DetailShell({
      title: '珍藏作品',
      onBack: () => KagNav.close()
    }) {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          if (this.errorText.length > 0) {
            Text(this.errorText)
              .fontSize(Theme.type.subhead)
              .fontColor(Theme.colors().danger)
              .width('100%')
          }
          AppButton({
            label: this.photos.length > 0 ? `已选 ${this.photos.length} 张，继续添加` : '拍照或从相册选择',
            variant: 'secondary',
            onTap: () => {
              void this.addPhotos()
            }
          })
          if (this.photos.length > 0) {
            Scroll() {
              Row({ space: 8 }) {
                ForEach(this.photos, (u: string) => {
                  Image(u)
                    .width(88)
                    .height(88)
                    .objectFit(ImageFit.Cover)
                    .borderRadius(8)
                }, (u: string) => u)
              }
            }
            .scrollable(ScrollDirection.Horizontal)
            .scrollBar(BarState.Off)
            .width('100%')
          }
          Text('作品名称')
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
          TextInput({ text: this.title, placeholder: '例如：下雨的星期天' })
            .onChange((v: string) => {
              this.title = v
            })
          AppDatePickerField({
            label: '创作日期',
            value: this.createdOn,
            placeholder: '选择日期',
            minDaysFromToday: -3650,
            maxDaysFromToday: 0,
            onChange: (v: string) => {
              this.createdOn = v
            }
          })
          Text('当时年龄')
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
          TextInput({ text: this.ageLabel, placeholder: '例如：4岁3个月' })
            .onChange((v: string) => {
              this.ageLabel = v
            })
          Text('创作故事 / 心情')
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
          TextArea({ text: this.story, placeholder: '尽量用孩子的原话' })
            .height(96)
            .onChange((v: string) => {
              this.story = v
            })
          AppButton({
            label: this.saving ? '保存中…' : '保存到时间线',
            variant: 'primary',
            disabled: this.saving,
            onTap: () => {
              void this.save()
            }
          })
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          bottom: Theme.space.s10
        })
      }
      .width('100%')
      .layoutWeight(1)
    }
  }
}
