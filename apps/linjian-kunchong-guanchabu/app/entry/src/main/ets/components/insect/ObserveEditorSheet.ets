import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppDatePickerField, AppTimePickerField } from '../design-system/AppDatePickerField'
import { AppNavBar } from '../design-system/AppNavBar'
import { Observation, TagPreset, WeatherOption } from '../../models/ObservationModels'
import { ObservationStore } from '../../services/ObservationStore'
import { PhotoPickService } from '../../services/PhotoPickService'
import { LocationHelper } from '../../services/LocationHelper'
import { PermissionHelper } from '../../services/PermissionHelper'
import { AppContextService } from '../../services/AppContextService'

@Component
export struct ObserveEditorSheet {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop editId: string = ''
  onClose: () => void = () => {}
  onSaved: () => void = () => {}
  @State draft: Observation = Observation.createNew()
  @State toastText: string = ''
  @State saving: boolean = false
  private weathers: WeatherOption[] = WeatherOption.all()
  private presets: string[] = TagPreset.all()

  aboutToAppear(): void {
    void this.bootstrap()
  }

  private async bootstrap(): Promise<void> {
    if (this.editId.length === 0) {
      this.draft = Observation.createNew()
      return
    }
    const found = await ObservationStore.findById(this.editId)
    if (found !== undefined) {
      this.draft = found
    }
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2400)
  }

  private hasTag(tag: string): boolean {
    for (const t of this.draft.tags) {
      if (t === tag) {
        return true
      }
    }
    return false
  }

  private toggleTag(tag: string): void {
    const next: string[] = []
    let removed = false
    for (const t of this.draft.tags) {
      if (t === tag) {
        removed = true
      } else {
        next.push(t)
      }
    }
    if (!removed) {
      next.push(tag)
    }
    this.draft.tags = next
  }

  private async pickAlbum(): Promise<void> {
    const ctx = AppContextService.getContext()
    if (ctx === null) {
      this.showToast('无法打开相册')
      return
    }
    const path = await PhotoPickService.pickAlbum(ctx)
    if (path.length > 0) {
      this.draft.photoUri = path
    }
  }

  private async pickCamera(): Promise<void> {
    const ctx = AppContextService.getContext()
    if (ctx === null) {
      this.showToast('无法打开相机')
      return
    }
    const perm = await PermissionHelper.ensureCamera(ctx)
    if (!perm.granted) {
      this.showToast(perm.message.length > 0 ? perm.message : '未获得相机权限，可改用相册')
      return
    }
    const path = await PhotoPickService.capture(ctx)
    if (path.length > 0) {
      this.draft.photoUri = path
    }
  }

  private async fillLocation(): Promise<void> {
    const ctx = AppContextService.getContext()
    if (ctx === null) {
      this.showToast('无法获取定位')
      return
    }
    const perm = await PermissionHelper.ensureLocation(ctx)
    if (!perm.granted) {
      this.showToast(perm.message)
      return
    }
    const loc = await LocationHelper.current()
    if (loc.label.length === 0) {
      this.showToast('未能获取位置，请手动填写')
      return
    }
    this.draft.location = loc.label
    this.draft.latitude = loc.latitude
    this.draft.longitude = loc.longitude
  }

  private async save(): Promise<void> {
    if (this.draft.name.trim().length === 0) {
      this.showToast('请填写昆虫名称')
      return
    }
    this.saving = true
    this.draft.name = this.draft.name.trim()
    await ObservationStore.save(this.draft)
    this.saving = false
    this.onSaved()
    this.onClose()
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column() {
        AppNavBar({ title: this.editId.length > 0 ? '编辑观察' : '新建观察', onBack: (): void => this.onClose() })
        Scroll() {
          Column({ space: Theme.space.s4 }) {
            this.PhotoBlock()
            this.FieldLabel('昆虫名称')
            TextInput({ text: this.draft.name, placeholder: '例如：七星瓢虫' })
              .onChange((v: string): void => { this.draft.name = v })
            this.FieldLabel('发现地点')
            TextInput({ text: this.draft.location, placeholder: '手动填写，或点击获取定位' })
              .onChange((v: string): void => { this.draft.location = v })
            AppButton({ label: '获取地点', variant: 'secondary', onTap: (): void => { void this.fillLocation() } })
            AppDatePickerField({
              label: '观察日期',
              value: this.draft.date,
              minDaysFromToday: -730,
              maxDaysFromToday: 0,
              onChange: (v: string): void => { this.draft.date = v }
            })
            AppTimePickerField({
              label: '观察时间',
              value: this.draft.time,
              onChange: (v: string): void => { this.draft.time = v }
            })
            this.FieldLabel('天气')
            this.WeatherRow()
            this.FieldLabel('行为描述')
            TextArea({ text: this.draft.behavior, placeholder: '它在做什么？飞行、觅食、停歇…' })
              .height(90)
              .onChange((v: string): void => { this.draft.behavior = v })
            this.FieldLabel('标签')
            this.TagRow()
            Row() {
              Text('收藏这条记录')
                .fontSize(Theme.type.body)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .layoutWeight(1)
              Toggle({ type: ToggleType.Switch, isOn: this.draft.isFavorite })
                .selectedColor(Theme.colors().brandPrimary)
                .onChange((v: boolean): void => { this.draft.isFavorite = v })
            }
            .width('100%')
            AppButton({
              label: this.saving ? '保存中…' : '保存观察',
              disabled: this.saving,
              onTap: (): void => { void this.save() }
            })
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().brandOnPrimary)
          .padding(12)
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .margin({ top: 56 })
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  FieldLabel(text: string) {
    Text(text)
      .fontSize(Theme.type.caption)
      .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
      .width('100%')
  }

  @Builder
  PhotoBlock() {
    Column({ space: Theme.space.s2 }) {
      if (this.draft.photoUri.length > 0) {
        Image(this.draft.photoUri)
          .width('100%')
          .height(168)
          .objectFit(ImageFit.Cover)
          .borderRadius(Theme.radius.lg)
      } else {
        Column() {
          Text('添加观察照片')
            .fontSize(Theme.type.body)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        }
        .width('100%')
        .height(120)
        .justifyContent(FlexAlign.Center)
        .borderRadius(Theme.radius.lg)
        .border({ width: 1, color: Theme.colors().strokeStrong, style: BorderStyle.Dashed })
      }
      Row({ space: Theme.space.s3 }) {
        AppButton({ label: '拍照', variant: 'secondary', onTap: (): void => { void this.pickCamera() } })
        AppButton({ label: '相册', variant: 'secondary', onTap: (): void => { void this.pickAlbum() } })
      }
      .width('100%')
    }
    .width('100%')
  }

  @Builder
  WeatherRow() {
    Flex({ wrap: FlexWrap.Wrap }) {
      ForEach(this.weathers, (w: WeatherOption) => {
        Text(w.label)
          .fontSize(Theme.type.bodyS)
          .fontColor(this.draft.weather === w.key ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
          .padding({ left: 14, right: 14, top: 8, bottom: 8 })
          .margin({ right: 8, bottom: 8 })
          .backgroundColor(this.draft.weather === w.key ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
          .borderRadius(Theme.radius.pill)
          .onClick((): void => { this.draft.weather = w.key })
      }, (w: WeatherOption) => w.key)
    }
    .width('100%')
  }

  @Builder
  TagRow() {
    Flex({ wrap: FlexWrap.Wrap }) {
      ForEach(this.presets, (tag: string) => {
        Text(tag)
          .fontSize(Theme.type.bodyS)
          .fontColor(this.hasTag(tag) ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
          .padding({ left: 14, right: 14, top: 8, bottom: 8 })
          .margin({ right: 8, bottom: 8 })
          .backgroundColor(this.hasTag(tag) ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
          .borderRadius(Theme.radius.pill)
          .onClick((): void => this.toggleTag(tag))
      }, (tag: string) => tag)
    }
    .width('100%')
  }
}
