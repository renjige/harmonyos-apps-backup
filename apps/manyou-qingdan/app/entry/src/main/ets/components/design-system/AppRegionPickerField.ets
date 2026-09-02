import { Theme } from './Theme'
import { AppButton } from './AppButton'
import { AppIcon } from './AppIcon'
import { RegionCatalog } from './RegionCatalog'

/** 省市区三级联动 — TextPicker 半屏面板，禁止手输「省市区」 */
@Component
export struct AppRegionPickerField {
  @Prop label: string = '服务地区'
  @Prop province: string = ''
  @Prop city: string = ''
  @Prop district: string = ''
  @Prop placeholder: string = '请选择省 / 市 / 区'
  onRegionChange: (province: string, city: string, district: string) => void = () => {}

  @State showPanel: boolean = false
  @State draftProvince: string = ''
  @State draftCity: string = ''
  @State draftDistrict: string = ''
  @State provinceRange: string[] = []
  @State cityRange: string[] = []
  @State districtRange: string[] = []
  @State provinceIndex: number = 0
  @State cityIndex: number = 0
  @State districtIndex: number = 0

  private displayText(): string {
    if (this.province.length > 0 && this.city.length > 0 && this.district.length > 0) {
      return `${this.province} ${this.city} ${this.district}`
    }
    return this.placeholder
  }

  private openPanel(): void {
    const fallback = RegionCatalog.defaultSelection()
    this.draftProvince = this.province.length > 0 ? this.province : fallback.province
    this.draftCity = this.city.length > 0 ? this.city : fallback.city
    this.draftDistrict = this.district.length > 0 ? this.district : fallback.district
    this.syncRanges()
    this.showPanel = true
  }

  private syncRanges(): void {
    this.provinceRange = RegionCatalog.provinceNames()
    this.provinceIndex = RegionCatalog.indexOf(this.provinceRange, this.draftProvince)
    if (this.provinceRange.length > 0) {
      this.draftProvince = this.provinceRange[this.provinceIndex]
    }
    this.cityRange = RegionCatalog.cityNames(this.draftProvince)
    this.cityIndex = RegionCatalog.indexOf(this.cityRange, this.draftCity)
    if (this.cityRange.length > 0) {
      this.draftCity = this.cityRange[this.cityIndex]
    } else {
      this.draftCity = ''
    }
    this.districtRange = RegionCatalog.districtNames(this.draftProvince, this.draftCity)
    this.districtIndex = RegionCatalog.indexOf(this.districtRange, this.draftDistrict)
    if (this.districtRange.length > 0) {
      this.draftDistrict = this.districtRange[this.districtIndex]
    } else {
      this.draftDistrict = ''
    }
  }

  private onProvincePick(index: number): void {
    this.provinceIndex = index
    if (index >= 0 && index < this.provinceRange.length) {
      this.draftProvince = this.provinceRange[index]
    }
    this.cityRange = RegionCatalog.cityNames(this.draftProvince)
    this.cityIndex = 0
    if (this.cityRange.length > 0) {
      this.draftCity = this.cityRange[0]
    } else {
      this.draftCity = ''
    }
    this.districtRange = RegionCatalog.districtNames(this.draftProvince, this.draftCity)
    this.districtIndex = 0
    if (this.districtRange.length > 0) {
      this.draftDistrict = this.districtRange[0]
    } else {
      this.draftDistrict = ''
    }
  }

  private onCityPick(index: number): void {
    this.cityIndex = index
    if (index >= 0 && index < this.cityRange.length) {
      this.draftCity = this.cityRange[index]
    }
    this.districtRange = RegionCatalog.districtNames(this.draftProvince, this.draftCity)
    this.districtIndex = 0
    if (this.districtRange.length > 0) {
      this.draftDistrict = this.districtRange[0]
    } else {
      this.draftDistrict = ''
    }
  }

  private onDistrictPick(index: number): void {
    this.districtIndex = index
    if (index >= 0 && index < this.districtRange.length) {
      this.draftDistrict = this.districtRange[index]
    }
  }

  private confirm(): void {
    this.onRegionChange(this.draftProvince, this.draftCity, this.draftDistrict)
    this.showPanel = false
  }

  build() {
    Stack() {
      Row() {
        Column({ space: 4 }) {
          Text(this.label)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textTertiary)
            .width('100%')
          Text(this.displayText())
            .fontSize(Theme.type.body)
            .fontColor(this.province.length > 0 ? Theme.colors().textPrimary : Theme.colors().textTertiary)
            .width('100%')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
      }
      .width('100%')
      .height(48)
      .padding({ left: 12, right: 12 })
      .backgroundColor(Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.sm)
      .border({ width: 1, color: Theme.colors().strokeHairline })
      .onClick(() => this.openPanel())

      if (this.showPanel) {
        Column() {
          Blank()
            .layoutWeight(1)
            .backgroundColor('rgba(0,0,0,0.35)')
            .onClick(() => {
              this.showPanel = false
            })
          Column({ space: Theme.space.s3 }) {
            Text('选择服务地区')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
            Row() {
              TextPicker({ range: this.provinceRange, selected: this.provinceIndex })
                .layoutWeight(1)
                .onChange((_value: string | string[], index: number | number[]) => {
                  if (typeof index === 'number') {
                    this.onProvincePick(index)
                  }
                })
              TextPicker({ range: this.cityRange, selected: this.cityIndex })
                .layoutWeight(1)
                .onChange((_value: string | string[], index: number | number[]) => {
                  if (typeof index === 'number') {
                    this.onCityPick(index)
                  }
                })
              TextPicker({ range: this.districtRange, selected: this.districtIndex })
                .layoutWeight(1)
                .onChange((_value: string | string[], index: number | number[]) => {
                  if (typeof index === 'number') {
                    this.onDistrictPick(index)
                  }
                })
            }
            .width('100%')
            .height(180)

            Row({ space: Theme.space.s3 }) {
              AppButton({
                label: '取消',
                variant: 'ghost',
                onTap: () => {
                  this.showPanel = false
                }
              }).layoutWeight(1)
              AppButton({
                label: '确定',
                onTap: () => this.confirm()
              }).layoutWeight(1)
            }
            .width('100%')
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius({ topLeft: Theme.radius.xl, topRight: Theme.radius.xl })
        }
        .width('100%')
        .height('100%')
      }
    }
    .width('100%')
  }
}
