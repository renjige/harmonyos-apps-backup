import { Theme } from '../components/design-system/Theme'
import { AppNavBar } from '../components/design-system/AppNavBar'
import { AppCard } from '../components/design-system/AppCard'
import { AppListRow } from '../components/design-system/AppListRow'
import { ContentCover } from '../components/common/ContentCover'
import { ContentService } from '../services/ContentService'
import { CompanyProfile, CertificateItem, HonorItem } from '../models/ZhukeModels'

@Component
export struct QualificationPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State profile: CompanyProfile = new CompanyProfile()
  @State certificates: CertificateItem[] = []
  @State honors: HonorItem[] = []
  onBack: () => void = () => {}
  onOpenHonor: (id: string) => void = (_id: string) => {}

  aboutToAppear(): void {
    this.profile = ContentService.company()
    this.certificates = ContentService.certificates()
    this.honors = ContentService.honors()
  }

  build() {
    Column() {
      AppNavBar({ title: '企业资质', onBack: () => this.onBack() })

      Scroll() {
        Column({ space: Theme.space.s5 }) {
          AppCard({ title: '企业简介', variant: 'inverse' }) {
            Column({ space: Theme.space.s2 }) {
              Text(`成立 ${this.profile.foundedYear} 年 · 注册资本 ${this.profile.registeredCapital}`)
                .fontSize(Theme.type.footnote)
                .fontColor(Theme.colors().textOnInverse)
                .opacity(0.85)
              Text(this.profile.intro)
                .fontSize(Theme.type.callout)
                .fontColor(Theme.colors().textOnInverse)
                .lineHeight(24)
            }
            .alignItems(HorizontalAlign.Start)
            .width('100%')
          }

          AppCard({ title: '企业文化' }) {
            Text(this.profile.culture)
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .lineHeight(24)
          }

          AppCard({ title: '企业愿景' }) {
            Text(this.profile.vision)
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          }

          Text('荣誉资质')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')

          Column() {
            ForEach(this.honors, (h: HonorItem, index: number) => {
              AppListRow({
                title: h.title,
                subtitle: `${h.year} 年`,
                showDivider: index < this.honors.length - 1,
                onTap: () => this.onOpenHonor(h.id)
              })
            }, (h: HonorItem) => h.id)
          }
          .padding({ left: Theme.space.s3, right: Theme.space.s3 })
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.md)

          Text('证书展示')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')

          ForEach(this.certificates, (c: CertificateItem) => {
            Row({ space: Theme.space.s3 }) {
              ContentCover({
                imageKey: c.coverKey,
                coverHeight: 96,
                coverRadius: Theme.radius.sm,
                showGradient: false
              })
              .width(72)
              Column({ space: Theme.space.s1 }) {
                Text(c.name)
                  .fontSize(Theme.type.subhead)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .width('100%')
                Text(`发证机关：${c.issuer}`)
                  .fontSize(Theme.type.footnote)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .width('100%')
                Text(`有效期至：${c.validUntil}`)
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().textTertiary)
                  .width('100%')
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)
            }
            .width('100%')
            .padding(Theme.space.s3)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
          }, (c: CertificateItem) => c.id)
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          bottom: Theme.space.s8
        })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
