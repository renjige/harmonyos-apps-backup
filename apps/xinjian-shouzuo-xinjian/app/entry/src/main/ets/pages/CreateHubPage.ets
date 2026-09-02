import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { CreatePage } from './CreatePage'
import { InspirationPage } from './InspirationPage'
import { WorkshopPage } from './WorkshopPage'

class CreateSegment {
  id: number = 0
  label: string = ''
}

@Component
export struct CreateHubPage {
  onRequireAuth: () => void = () => {}
  @StorageLink('createHubSegment') segment: number = 0
  @StorageLink('createFormOpen') createFormOpen: boolean = false
  private segments: CreateSegment[] = CreateHubPage.buildSegments()

  private static buildSegments(): CreateSegment[] {
    const out: CreateSegment[] = []
    const s0 = new CreateSegment()
    s0.id = 0
    s0.label = '作品'
    out.push(s0)
    const s1 = new CreateSegment()
    s1.id = 1
    s1.label = '灵感'
    out.push(s1)
    const s2 = new CreateSegment()
    s2.id = 2
    s2.label = '制作助手'
    out.push(s2)
    return out
  }

  build() {
    Column() {
      if (!this.createFormOpen) {
        AppHeader({ title: '创作', subtitle: '作品记录 · 灵感笔记 · 制作助手' })
        Row({ space: Theme.space.s2 }) {
          ForEach(this.segments, (s: CreateSegment) => {
            Text(s.label)
              .fontSize(Theme.type.subhead)
              .fontWeight(this.segment === s.id ? FontWeight.Medium : FontWeight.Normal)
              .fontColor(this.segment === s.id ?
                Theme.colors().textOnInverse : Theme.colors().textSecondary)
              .padding({ left: 14, right: 14, top: 8, bottom: 8 })
              .backgroundColor(this.segment === s.id ?
                Theme.colors().brandDeep : Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.pill)
              .onClick(() => { this.segment = s.id })
          }, (s: CreateSegment) => `${s.id}`)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s2 })
      }

      Column() {
        if (this.segment === 0) {
          CreatePage({ embedded: true, onRequireAuth: (): void => this.onRequireAuth() })
        } else if (this.segment === 1) {
          InspirationPage({ embedded: true, onRequireAuth: (): void => this.onRequireAuth() })
        } else {
          WorkshopPage({ embedded: true })
        }
      }
      .layoutWeight(1)
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }
}
